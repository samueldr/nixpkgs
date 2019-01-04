{ stdenv, buildPackages, targetPlatform, hostPlatform, fetchFromGitHub, fetchpatch, libuuid, python2, findutils }:

let
# Given a platform, returns the edk2-valid arch.
envToArch = env:
  if env.isi686 then
    "IA32"
  else if env.isx86_64 then
    "X64"
  else if env.isAarch64 then
    "AARCH64"
  else if env.isAarch32 then
    "ARM"
  else
    throw "Unsupported architecture" 
;

buildPythonEnv = buildPackages.python2.withPackages(ps: [ps.tkinter]);
pythonEnv = python2.withPackages(ps: [ps.tkinter]);

targetArch = envToArch targetPlatform;
hostArch = envToArch hostPlatform;

edk2 = stdenv.mkDerivation {
  name = "edk2-2018-12-26";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "tianocore";
    repo = "edk2";
    rev = "2bb4a7ca6299298f84da4657576b140f178c7458";
    sha256 = "19jc5h58kwi9l2k2izpsvr35hmjpqiz671y39sikk8b95rj1ycm5";
  };

  nativeBuildInputs = [ libuuid buildPythonEnv ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  makeFlags = [
    "-C" "BaseTools"
    # HOST_ARCH is detected through uname, better specify it.
    "HOST_ARCH=${hostArch}"
    "ARCH=${targetArch}"
  ];

  hardeningDisable = [ "format" "fortify" ];

  installPhase = ''
    mkdir -vp $out
    mv -v BaseTools $out
    mv -v EdkCompatibilityPkg $out
    mv -v edksetup.sh $out
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Intel EFI development kit";
    homepage = https://sourceforge.net/projects/edk2/;
    license = stdenv.lib.licenses.bsd2;
    branch = "UDK2017";
    platforms = ["x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux"];
  };

  passthru = {
    inherit targetArch;

    # Generic edk2-based build.
    #
    # Pass a list of derivations as `workspace` which will be merged in the order
    # given into a unified workspace directory. EDK2 and the built EDK2 are already
    # added to the workspace for you.
    #
    # When using `edk2.setup`, please also consider adding `src` or `srcs` as
    # an attribute to your derivation pointing to the specific source, as a
    # convenience to the end-user.
    setup = projectDscPath: attrs: rec {
      hostArch = buildPackages.edk2.targetArch;

      workspace = [
        edk2.src
        edk2
      ] ++ attrs.workspace or [];

      nativeBuildInputs = [ buildPythonEnv findutils ] ++ attrs.nativeBuildInputs or [];

      # FIXME : figure out a clean way to name package paths.
      # Right now, we get 0000000000000000000000000000000-source for most
      # packages; this is not nice to debug things. Ideally, a name should be
      # given in addition to a path, but this makes the API messy :/.
      unpackPhase = ''
        runHook preUnpack

        export PACKAGES_PATH=""
        for i in ${stdenv.lib.concatStringsSep " " workspace}; do
          echo "Adding to workspace: $(basename $i)"
          cp -prf $i ./
          if [[ "$PACKAGES_PATH" != "" ]]; then
          PACKAGES_PATH+=":"
          fi
          PACKAGES_PATH+="$PWD/$(basename $i)"
        done

        # Makes the whole workspace writable
        chmod -R u+rw -- *

        patchShebangs .
        export WORKSPACE="$PWD"
        runHook postUnpack
      '';

      # Configures the build system among other options, to build the given `projectDscPath`
      configurePhase = ''
        mkdir -pv Conf

        cp ${edk2}/BaseTools/Conf/target.template Conf/target.txt
        sed -i Conf/target.txt \
          -e 's|DEBUG|RELEASE|'

        ln -sv ${edk2}/BaseTools BaseTools

        . $(basename ${edk2})/edksetup.sh BaseTools
      '';

      # Generic build phase. It will build whatever was configured using `projectDscPath`.
      # FIXME : -p */${projectDscPath} might fail when multiple projects
      #         in the workspace define the same project path.
      # FIXME: instead use ${workspace} order and stop on first found
      buildPhase = ''
        # This is required, even though it is set in target.txt in edk2/default.nix.
        export EDK2_TOOLCHAIN=GCC49

        # Configures for cross-compiling
        export ''${EDK2_TOOLCHAIN}_${hostArch}_PREFIX=${stdenv.targetPlatform.config}-
        export EDK2_HOST_ARCH=${hostArch}

        build \
          -n $NIX_BUILD_CORES \
          ${stdenv.lib.escapeShellArgs (attrs.buildFlags or [])} \
          -a ${hostArch} \
          -t $EDK2_TOOLCHAIN \
          -p */${projectDscPath}
      '';

      installPhase = ''
        mv -v Build/*/* $out
      '';
    } // (removeAttrs attrs [ "nativeBuildInputs" ] );

    srcs = {
      platforms = fetchFromGitHub {
        #fetchSubmodules = true;
        owner = "tianocore";
        repo = "edk2-platforms";
        rev = "f685a57901c328b23c4f3ac7ddf472d897d5e360";
        sha256 = "0i36vvf03g1wrpf1ir7i9z3m3mcp3panms548wnmhn8l0gvida7z";
      };
      non-osi = fetchFromGitHub {
        #fetchSubmodules = true;
        owner = "tianocore";
        repo = "edk2-non-osi";
        rev = "1e2ca640be54d7a4d5d804c4f33894d099432de3";
        sha256 = "1i10gsv47cvsh0i4hh6rvawqkl1jp6d725rjfvkjz6nq3bypmc4n";
      };
    };
  };
};

in

edk2
