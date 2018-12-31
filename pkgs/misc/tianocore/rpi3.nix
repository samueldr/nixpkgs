{ stdenv
, findutils
, lib
, buildPackages
, fetchFromGitHub
, symlinkJoin
, runCommand
, edk2
}:

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
in
stdenv.mkDerivation (edk2.setup projectDscPath rec {
  version = "2018-12-19";
  name = "tianocore-rpi3-${version}";

  nativeBuildInputs = [ findutils ];

  # This acts as a big merge of all those "edk2 workspaces"
  # TODO : rework the generic edk2 build to work with un-merged workspaces.
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

  buildPhase = lib.optionalString crossCompiling ''
    # This is required, even though it is set in target.txt in edk2/default.nix.
    export EDK2_TOOLCHAIN=GCC49

    # Configures for cross-compiling
    export ''${EDK2_TOOLCHAIN}_${targetArch}_PREFIX=${stdenv.targetPlatform.config}-
    export EDK2_HOST_ARCH=${targetArch}
    '' + ''
    build \
      -n $NIX_BUILD_CORES \
      -a ${targetArch} \
      ${lib.optionalString crossCompiling "-t $EDK2_TOOLCHAIN"}
  '';

  platforms = [ "none" ];
})
