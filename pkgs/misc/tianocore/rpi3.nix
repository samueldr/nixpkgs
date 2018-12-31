{ stdenv
, fetchFromGitHub
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

  src = RaspberryPiPkg_src;

  outputs = [ "out" "fd" ];

  workspace = [
    edk2.src
    edk2
    edk2.srcs.platforms
    edk2.srcs.non-osi
    RaspberryPiPkg_src
  ];

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
