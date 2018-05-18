{ fetchFromGitHub, fetchurl, buildMaven, maven, jdk, makeWrapper, stdenv, ... }:

let
  tycho_version = "1.0.0";
  tycho_name = "tycho-bundles-external";
  tychoBundlesExternal = fetchurl {
    url = "http://central.maven.org/maven2/org/eclipse/tycho/${tycho_name}/${tycho_version}/${tycho_name}-${tycho_version}.zip";
    sha256 = "1n1s47h5wz6zyrfgxq8hr8nzm7dfkgvk2lwfh3whdz6x8qvn4waf";
  };
in
stdenv.mkDerivation rec {
  name = "dbeaver-${version}";
  version = "5.0.5";

  src = fetchFromGitHub {
    owner = "dbeaver";
    repo = "dbeaver";
    sha256 = "1j0ydcidsw98wwq8phqvvhag5ilfws3wj9jqg2s0f9dx3yzkn1d6";
    rev = version;
  };
  # Adapted from pkgs/servers/exhibitor/default.nix
  # which in turn is adapted from https://github.com/volth/nixpkgs/blob/6aa470dfd57cae46758b62010a93c5ff115215d7/pkgs/applications/networking/cluster/hadoop/default.nix#L20-L32

  fetchedMavenDeps = stdenv.mkDerivation {
    name = "dbeaver-${version}-maven-deps";
    inherit src nativeBuildInputs;
    buildPhase = ''
      cd ${pomFileDir};
      echo "Installing tycho bundles external..."
      #mvn install org.eclipse.tycho:tycho-bundles-external:zip:1.0.0 -Dmaven.repo.local=$out/.m2
      #echo

      echo "Installing project depdendencies..."
      while timeout --kill-after=21m 20m mvn --batch-mode package -Dmaven.repo.local=$out/.m2; [ $? = 124 ]; do
        echo "maven hangs while downloading :("
      done
      #mvn install:install-file -Dmaven.repo.local=$out/.m2 \
      #  -DgroupId=org.eclipse.tycho \
      #  -DartifactId=tycho-bundles-external \
      #  -Dversion={tycho_version} \
      #  -Dpackaging=zip \
      #  -Dfile=${tychoBundlesExternal}
    '';

    installPhase = ''
      cp -prf . $out/tmp

      # delete files with lastModified timestamps inside
      find $out/.m2 -type f \! -regex '.+\(pom\|jar\|xml\|sha1\)' -delete
      rm -rf $out/.m2/.cache
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    # --sdr: NOTE: This is stable!
    #outputHash = "1lzliwicpcyvr00vyph46p62lfkbq70pifr1nh9pqrlxcbap1118";
    outputHash = "1lzliwicpcyvr00vyph46p62lfkbq70pifr1nh9pqrlxcb111118";
  };

  pomFileDir = "./";

  nativeBuildInputs = [ maven ];
  buildInputs = [ makeWrapper ];
        #cp -dpR ${fetchedTychoMavenDeps}/.m2 ./ && chmod +w -R .m2 && \
  buildPhase = ''
      repo_local=$(
        cp -dpR ${fetchedMavenDeps}/.m2 ./      && chmod +w -R .m2 && \
        pwd
      )/.m2
      echo "Building dbeaver"
      echo ${fetchedMavenDeps}
      ls -lA ${fetchedMavenDeps}
      exit 1
      #mvn --batch-mode package  -Dmaven.repo.local=$repo_local

  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/java
    mv target/$name.jar $out/share/java/
    makeWrapper ${jdk}/bin/java $out/bin/startExhibitor.sh --add-flags "-jar $out/share/java/$name.jar" --suffix PATH : ${stdenv.lib.makeBinPath [ jdk ]}
  '';

  meta = with stdenv.lib; {
    homepage = https://dbeaver.jkiss.org;
    description = "Universal SQL Client for developers, SQL programmers, database administrators and analysts. Supports all popular databases: MySQL, PostgreSQL, MariaDB, SQLite, etc";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}


#{ stdenv, fetchurl, makeDesktopItem, makeWrapper
#, fontconfig, freetype, glib, gtk2
#, jdk, libX11, libXrender, libXtst, zlib }:
#
## The build process is almost like eclipse's.
## See `pkgs/applications/editors/eclipse/*.nix`
#
#stdenv.mkDerivation rec {
#  name = "dbeaver-ce-${version}";
#  version = "5.0.5";
#
#  desktopItem = makeDesktopItem {
#    name = "dbeaver";
#    exec = "dbeaver";
#    icon = "dbeaver";
#    desktopName = "dbeaver";
#    comment = "SQL Integrated Development Environment";
#    genericName = "SQL Integrated Development Environment";
#    categories = "Application;Development;";
#  };
#
#  buildInputs = [
#    fontconfig freetype glib gtk2
#    jdk libX11 libXrender libXtst zlib
#  ];
#
#  nativeBuildInputs = [
#    makeWrapper
#  ];
#
#  src = fetchurl {
#    url = "https://dbeaver.io/files/${version}/dbeaver-ce-${version}-linux.gtk.x86_64.tar.gz";
#    sha256 = "1rcskrv8d3rjcfcn1sxzcaxnvmzgdsbjc9m11li8i4rln712ysza";
#  };
#
#  installPhase = ''
#    mkdir -p $out/
#    cp -r . $out/dbeaver
#
#    # Patch binaries.
#    interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
#    patchelf --set-interpreter $interpreter $out/dbeaver/dbeaver
#
#    makeWrapper $out/dbeaver/dbeaver $out/bin/dbeaver \
#      --prefix PATH : ${jdk}/bin \
#      --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath ([ glib gtk2 libXtst ])} \
#      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
#
#    # Create desktop item.
#    mkdir -p $out/share/applications
#    cp ${desktopItem}/share/applications/* $out/share/applications
#
#    mkdir -p $out/share/pixmaps
#    ln -s $out/dbeaver/icon.xpm $out/share/pixmaps/dbeaver.xpm
#  '';
#
#  meta = with stdenv.lib; {
#    homepage = https://dbeaver.io/;
#    description = "Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more";
#    longDescription = ''
#      Free multi-platform database tool for developers, SQL programmers, database
#      administrators and analysts. Supports all popular databases: MySQL,
#      PostgreSQL, MariaDB, SQLite, Oracle, DB2, SQL Server, Sybase, MS Access,
#      Teradata, Firebird, Derby, etc.
#    '';
#    license = licenses.asl20;
#    platforms = [ "x86_64-linux" ];
#    maintainers = [ maintainers.samueldr ];
#  };
#}
