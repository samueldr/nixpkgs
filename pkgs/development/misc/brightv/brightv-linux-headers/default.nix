{ stdenvNoCC
, fetchzip
}:

stdenvNoCC.mkDerivation {
  pname = "brightv-linux-headers";
  version = "4";
  src = fetchzip {
    url = "http://www.chokanji.com/archive/brightv.linux.tar.gz";
    hash = "sha256-I0Hrh4eXB3D68pYCCR3rX5XLFd8mnEtdl0e2qc7RGfg=";
  };

  installPhase = ''
    mkdir -vp $out
    mv -v -t $out/ gnu/i386-unknown-gnu/include \
                   gnu/lib/gcc-lib/i386-unknown-gnu/2.95.2/specs
  '';

  # We're purposefully not moving the includes to `dev` since
  # this is an internal build step for the SDK.
  moveToDev = false;
  outputs = [
    "out"
  ];
}
