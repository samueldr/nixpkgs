{ stdenv, buildPackages, targetPlatform, buildPlatform, fetchFromGitHub, fetchpatch, libuuid, python2, findutils }:

let
# Given a stdenv, returns the edk2-valid arch.
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
hostArch = envToArch buildPlatform;

crossCompiling = stdenv.buildPlatform != stdenv.hostPlatform;

edk2 = stdenv.mkDerivation {
  name = "edk2-2018-12-26";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "tianocore";
    repo = "edk2";
    rev = "2bb4a7ca6299298f84da4657576b140f178c7458";
    sha256 = "19jc5h58kwi9l2k2izpsvr35hmjpqiz671y39sikk8b95rj1ycm5";
  };

  buildInputs = [ libuuid ];

  depsBuildBuild = [ buildPackages.stdenv.cc buildPackages.libuuid buildPythonEnv ];

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
    inherit targetArch hostArch;
    setup = projectDscPath: attrs: {
      buildInputs = stdenv.lib.optionals (attrs ? buildInputs) attrs.buildInputs;

      nativeBuildInputs = [ buildPythonEnv ] ++
        stdenv.lib.optionals (attrs ? nativeBuildInputs) attrs.nativeBuildInputs;

      depsBuildBuild = [ buildPackages.iasl ];

      # Configures the build system among other options, to build the given `projectDscPath`
      configurePhase = ''
        mkdir -pv Conf

        cp ${edk2}/BaseTools/Conf/target.template Conf/target.txt
        sed -i Conf/target.txt \
          -e 's|Nt32Pkg/Nt32Pkg.dsc|${projectDscPath}|' \
          -e 's|MYTOOLS|GCC49|' \
          -e 's|IA32|${targetArch}|' \
          -e 's|DEBUG|RELEASE|'\

        cp ${edk2}/BaseTools/Conf/tools_def.template Conf/tools_def.txt
        sed -i Conf/tools_def.txt \
          -e 's|DEFINE GCC48_IA32_PREFIX       = /usr/bin/|DEFINE GCC48_IA32_PREFIX       = ""|' \
          -e 's|DEFINE GCC48_X64_PREFIX        = /usr/bin/|DEFINE GCC48_X64_PREFIX        = ""|' \
          -e 's|DEFINE UNIX_IASL_BIN           = /usr/bin/iasl|DEFINE UNIX_IASL_BIN           = ${buildPackages.iasl}/bin/iasl|'

        export WORKSPACE="$PWD"
        export EFI_SOURCE="$PWD/EdkCompatibilityPkg"
        ln -sv ${edk2}/BaseTools BaseTools
        ln -sv ${edk2}/EdkCompatibilityPkg EdkCompatibilityPkg
        . ${edk2}/edksetup.sh BaseTools
      '';

      # Generic build phase with cross-compilation support.
      # It will build whatever was configured using `projectDscPath`.
      buildPhase = stdenv.lib.optionalString crossCompiling ''
        # This is required, even though it is set in target.txt in edk2/default.nix.
        export EDK2_TOOLCHAIN=GCC49

        # Configures for cross-compiling
        export ''${EDK2_TOOLCHAIN}_${targetArch}_PREFIX=${stdenv.targetPlatform.config}-
        export EDK2_HOST_ARCH=${targetArch}
        '' + ''
        build \
          -n $NIX_BUILD_CORES \
          ${attrs.buildFlags or ""} \
          -a ${targetArch} \
          ${stdenv.lib.optionalString crossCompiling "-t $EDK2_TOOLCHAIN"}
      '';

      installPhase = ''
        mv -v Build/*/* $out
      '';
    } // (removeAttrs attrs [ "buildInputs" "nativeBuildInputs" ] );

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
