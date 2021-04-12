{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "amlogic-firmware";
  version = "2021-01-29";

  src = fetchFromGitHub {
    repo = "amlogic-boot-fip";
    owner = "LibreELEC";
    rev = "ac20772f44b2b74c8f55331b5c91a277d0bfbc37";
    sha256 = "1z739644655w1wbfi3456qg9k1izrmn2xci6vjh4sb55cxydja15";
  };

  installPhase = ''
    # We're lazy... this will allow us to *just* copy everything in $out
    rm -v LICENSE README.md
    # Remove unneeded files; we're not re-using the downstream build infra.
    rm -v */aml_encrypt* */blx_fix.sh */*.py */fip_create
    mkdir -p $out
    mv -t $out/ *
  '';

  fixupPhase = ''
    echo "Fixup phase skipped..."
  '';

  meta = with lib; {
    description = "Firmware Image Package (FIP) sources used to sign Amlogic U-Boot binaries";
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [ samueldr ];
  };
}
