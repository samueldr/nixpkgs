{ stdenv
, findutils
, lib
, buildPackages
, fetchFromGitHub
, symlinkJoin
, runCommand
, edk2
}:

# FIXME : only allow building for targetArch == AARCH64

let
  RaspberryPiPkg_src = runCommand "RaspberryPiPkg-src" {} ''
    mkdir -p "$out"
    mkdir -vp $out/Platform/Broadcom
    ln -vs ${fetchFromGitHub {
      owner = "pbatard";
      repo = "RaspberryPiPkg";
      rev = "8be01f060dac38b6137f8abd3fff3cf4a00dcab6";
      sha256 = "1w9763ycw0ix2kz8mr8ayfbj2imfskv04321bb08wg2f6ivdfz3s";
    }} $out/Platform/Broadcom/Bcm283x
  '';

  projectDscPath = "Platform/Broadcom/Bcm283x/RaspberryPiPkg.dsc";

  inherit (edk2) src targetArch;

  crossCompiling = stdenv.buildPlatform != stdenv.hostPlatform;

  buildFlags = "";

  pkgs = [
    "UefiCpuPkg"
    "MdeModulePkg"
    "IntelFrameworkModulePkg"
    "PcAtChipsetPkg"
    "FatBinPkg"
    "EdkShellBinPkg"
    "MdePkg"
    "ShellPkg"
    "OptionRomPkg"
    "IntelFrameworkPkg"
    "FatPkg"
    "CryptoPkg"
    "SourceLevelDebugPkg"
    "ArmPkg"
    "ArmPlatformPkg"
    "ArmVirtPkg"
    "EmbeddedPkg"
    "OvmfPkg"
  ];
in
stdenv.mkDerivation (edk2.setup projectDscPath rec {
  version = "2018-12-19";
  name = "tianocore-rpi3-${version}";

  nativeBuildInputs = [ findutils ];

  #inherit src;

  #src = symlinkJoin {
  #  name = "${name}-src";
  #  paths = [
  #    edk2.src
  #    edk2
  #    edk2.srcs.platforms
  #    edk2.srcs.non-osi
  #    RaspberryPiPkg_src
  #  ];
  #};

  unpackPhase = ''
    for d in ${lib.concatStringsSep " " (builtins.map (d: "${d}") [
      edk2.src
      edk2
      edk2.srcs.platforms
      edk2.srcs.non-osi
      RaspberryPiPkg_src
    ])}; do
      (cd "$d"
      echo "Merging $d"
      find -L   -type d -exec mkdir -p "$NIX_BUILD_TOP/{}" ';'
      find -L ! -type d -exec cp -f '{}' "$NIX_BUILD_TOP/{}" ';'
      )
    done
    chmod +rw *
  '';

  ## Here we're copying directories instead of 
  #unpackPhase = ''
  #  for file in "${src}"/{${lib.concatStringsSep "," pkgs}}; do
  #    ln -sv "$file" .
  #  done
  #  for file in "${src}"/{${lib.concatStringsSep "," pkgs}}; do
  #    ln -sv "$file" .
  #  done
  #'';

    ## # Here, we're preparing the "workspace" as described in the README.
    ## # https://github.com/pbatard/RaspberryPiPkg#building
    ## # TODO : explore doing this like the OVMF derivation does.
    ## src = runCommand "${name}-src" {} ''
    ##   ## mkdir -p "$out"
    ##   ## cp -prf ${edk2} edk2
    ##   ## #cp -prf ${edk2}/BaseTools/

    ##   ## cp -prf ${edk2.srcs.platforms} edk2-platforms
    ##   ## cp -prf ${edk2.srcs.non-osi} edk2-non-osi
	##   ## chmod -R a+rw *
	##   ## mkdir -p edk2-platforms/Platform/Broadcom
    ##   ## cp -prf ${RaspberryPiPkg_src} edk2-platforms/Platform/Broadcom/Bcm283x
    ## '';

## FIXME : copied from edk2
#    configurePhase = ''
#        mkdir -v Conf
#
#        cp ${edk2}/BaseTools/Conf/target.template Conf/target.txt
#        sed -i Conf/target.txt \
#          -e 's|Nt32Pkg/Nt32Pkg.dsc|${projectDscPath}|' \
#          -e 's|MYTOOLS|GCC49|' \
#          -e 's|IA32|${targetArch}|' \
#          -e 's|DEBUG|RELEASE|'\
#
#        cp ${edk2}/BaseTools/Conf/tools_def.template Conf/tools_def.txt
#        sed -i Conf/tools_def.txt \
#          -e 's|DEFINE GCC48_IA32_PREFIX       = /usr/bin/|DEFINE GCC48_IA32_PREFIX       = ""|' \
#          -e 's|DEFINE GCC48_X64_PREFIX        = /usr/bin/|DEFINE GCC48_X64_PREFIX        = ""|' \
#          -e 's|DEFINE UNIX_IASL_BIN           = /usr/bin/iasl|DEFINE UNIX_IASL_BIN           = ${buildPackages.iasl}/bin/iasl|'
#
#        export WORKSPACE="$PWD"
#        export EFI_SOURCE="$PWD/EdkCompatibilityPkg"
#        ln -sv ${edk2}/BaseTools BaseTools
#        ln -sv ${edk2}/EdkCompatibilityPkg EdkCompatibilityPkg
#        . ${edk2}/edksetup.sh BaseTools
#	'';
#
#  buildPhase = lib.optionalString crossCompiling ''
#    # This is required, even though it is set in target.txt in edk2/default.nix.
#    export EDK2_TOOLCHAIN=GCC49
#
#    # Configures for cross-compiling
#    export ''${EDK2_TOOLCHAIN}_${targetArch}_PREFIX=${stdenv.targetPlatform.config}-
#    export EDK2_HOST_ARCH=${targetArch}
#    '' + ''
#    build \
#      -n $NIX_BUILD_CORES \
#      ${buildFlags} \
#      -a ${targetArch} \
#      ${lib.optionalString crossCompiling "-t $EDK2_TOOLCHAIN"}
#  '';

})


#{ stdenv, lib, edk2, nasm, iasl, seabios, openssl, secureBoot ? false }:
#
#let
#  projectDscPath = if stdenv.isi686 then
#    "OvmfPkg/OvmfPkgIa32.dsc"
#  else if stdenv.isx86_64 then
#    "OvmfPkg/OvmfPkgX64.dsc"
#  else if stdenv.isAarch64 || stdenv.isAarch32 then
#    "ArmVirtPkg/ArmVirtQemu.dsc"
#  else
#    throw "Unsupported architecture";
#
#  crossCompiling = stdenv.buildPlatform != stdenv.hostPlatform;
#
#  version = (builtins.parseDrvName edk2.name).version;
#
#  inherit (edk2) src targetArch;
#
#  buildFlags = if stdenv.isAarch64 then ""
#    else if seabios == null then ''${lib.optionalString secureBoot "-DSECURE_BOOT_ENABLE=TRUE"}''
#    else ''-D CSM_ENABLE -D FD_SIZE_2MB ${lib.optionalString secureBoot "-DSECURE_BOOT_ENABLE=TRUE"}'';
#in
#
#stdenv.mkDerivation (edk2.setup projectDscPath {
#  name = "OVMF-${version}";
#
#  inherit src;
#
#  outputs = [ "out" "fd" ];
#
#  # TODO: properly include openssl for secureBoot
#  buildInputs = [nasm iasl] ++ stdenv.lib.optionals (secureBoot == true) [ openssl ];
#
#  hardeningDisable = [ "stackprotector" "pic" "fortify" ];
#
#  unpackPhase = ''
#    # $fd is overwritten during the build
#    export OUTPUT_FD=$fd
#
#    for file in \
#      "${src}"/{UefiCpuPkg,MdeModulePkg,IntelFrameworkModulePkg,PcAtChipsetPkg,FatBinPkg,EdkShellBinPkg,MdePkg,ShellPkg,OptionRomPkg,IntelFrameworkPkg,FatPkg,CryptoPkg,SourceLevelDebugPkg};
#    do
#      ln -sv "$file" .
#    done
#
#    ${if stdenv.isAarch64 || stdenv.isAarch32 then ''
#      ln -sv ${src}/ArmPkg .
#      ln -sv ${src}/ArmPlatformPkg .
#      ln -sv ${src}/ArmVirtPkg .
#      ln -sv ${src}/EmbeddedPkg .
#      ln -sv ${src}/OvmfPkg .
#    '' else if seabios != null then ''
#        cp -r ${src}/OvmfPkg .
#        chmod +w OvmfPkg/Csm/Csm16
#        cp ${seabios}/Csm16.bin OvmfPkg/Csm/Csm16/Csm16.bin
#    '' else ''
#        ln -sv ${src}/OvmfPkg .
#    ''}
#
#    ${lib.optionalString secureBoot ''
#      ln -sv ${src}/SecurityPkg .
#      ln -sv ${src}/CryptoPkg .
#    ''}
#  '';
#
#  buildPhase = lib.optionalString crossCompiling ''
#    # This is required, even though it is set in target.txt in edk2/default.nix.
#    export EDK2_TOOLCHAIN=GCC49
#
#    # Configures for cross-compiling
#    export ''${EDK2_TOOLCHAIN}_${targetArch}_PREFIX=${stdenv.targetPlatform.config}-
#    export EDK2_HOST_ARCH=${targetArch}
#    '' + ''
#    build \
#      -n $NIX_BUILD_CORES \
#      ${buildFlags} \
#      -a ${targetArch} \
#      ${lib.optionalString crossCompiling "-t $EDK2_TOOLCHAIN"}
#  '';
#
#  postFixup = if stdenv.isAarch64 || stdenv.isAarch32 then ''
#    mkdir -vp $fd/FV
#    mkdir -vp $fd/AAVMF
#    mv -v $out/FV/QEMU_{EFI,VARS}.fd $fd/FV
#
#    # Uses Fedora dir layout: https://src.fedoraproject.org/cgit/rpms/edk2.git/tree/edk2.spec
#    # FIXME: why is it different from Debian dir layout? https://anonscm.debian.org/cgit/pkg-qemu/edk2.git/tree/debian/rules
#    dd of=$fd/AAVMF/QEMU_EFI-pflash.raw       if=/dev/zero bs=1M    count=64
#    dd of=$fd/AAVMF/QEMU_EFI-pflash.raw       if=$fd/FV/QEMU_EFI.fd conv=notrunc
#    dd of=$fd/AAVMF/vars-template-pflash.raw if=/dev/zero bs=1M    count=64
#  '' else ''
#    mkdir -vp $OUTPUT_FD/FV
#    mv -v $out/FV/OVMF{,_CODE,_VARS}.fd $OUTPUT_FD/FV
#  '';
#
#  dontPatchELF = true;
#
#  meta = {
#    description = "Sample UEFI firmware for QEMU and KVM";
#    homepage = https://github.com/tianocore/tianocore.github.io/wiki/OVMF;
#    license = stdenv.lib.licenses.bsd2;
#    platforms = ["x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux"];
#  };
#})
