{ stdenv
, lib
, fetchgit
, buildPackages
}:

stdenv.mkDerivation {
  pname = "mox-boot-builder";
  version = "v2022.08.30";
  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/mox-boot-builder.git";
    rev = "0290b2cd9e14041ef7bcd267840f30d6c0a92ceb";
    hash = "sha256-ZlbgJj/KgiDcF7Jl+wdNJi7iSivBIGF0W1qbrcIWBvk=";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [
    buildPackages.stdenv.cc # Needed as HOSTCC for build helpers during the build
  ];

  makeFlags = [
    "HOSTCC=${buildPackages.stdenv.cc.targetPrefix}cc"
    "CROSS_CM3=${buildPackages.gcc-arm-embedded}/bin/arm-none-eabi-"
    "wtmi_app.bin"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp wtmi_app.bin $out

    runHook postInstall
  '';
  meta = with lib; {
    description = "BL32 firmware for A3700 SOCs";
    license = licenses.unfreeRedistributableFirmware;
    maintainers = [ /* you! */ ];
    platforms = [ "aarch64-linux" ];
  };
}
