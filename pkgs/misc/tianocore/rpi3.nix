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
      # This fork is working on getting the code upstreamable.
      # https://github.com/pbatard/RaspberryPiPkg/projects/1
      owner = "pbatard";
      repo = "RaspberryPiPkg";
      rev = "8f37304a4ecb044843960e0925e22286bfd01fe8";
      sha256 = "1bvgn703i3wd6vjkvdzm3mxy3rlafqazljkzr0z2gpj91i981fy3";
    }} $out/Platform/Broadcom/Bcm283x
  '';

  projectDscPath = "Platform/Broadcom/Bcm283x/RaspberryPiPkg.dsc";

  crossCompiling = stdenv.buildPlatform != stdenv.hostPlatform;

  version = "2018-12-31";
in
stdenv.mkDerivation (edk2.setup projectDscPath {
  name = "tianocore-rpi3-${version}";

  outputs = [ "out" "fd" ];

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

  # Makes the `.fd` output.
  postFixup = ''
    mkdir -vp $fd/FV
    mv -v $out/FV/RPI_EFI.fd $fd/FV
  '';

  dontPatchELF = true;

  meta = {
    description = "Tiano Core UEFI for the Raspberry Pi 3";
    homepage = https://github.com/pbatard/RaspberryPiPkg;
    license = stdenv.lib.licenses.bsd2;
    platforms = ["aarch64-linux"];
  };
})
