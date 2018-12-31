{ stdenv, buildPackages, targetPlatform, buildPlatform, fetchFromGitHub, fetchpatch, libuuid, python2 }:

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

      configurePhase = ''
        mkdir -v Conf

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

      # This probably is not enough for most builds as it won't handle
      # setting targets or other needed flags to the `build` tool.
      buildPhase = "
        build
      ";

      installPhase = "mv -v Build/*/* $out";
    } // (removeAttrs attrs [ "buildInputs" ] );
  };
};

in

edk2
