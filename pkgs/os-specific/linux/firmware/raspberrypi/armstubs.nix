{ stdenv, fetchFromGitHub, cmake, pkgconfig }:

let
  inherit (stdenv.lib) optionals;
in
stdenv.mkDerivation {
  pname = "raspberrypi-armstubs";
  version = "2020-04-22";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "tools";
    rev = "86d54c61f9a23e5b438bef98f3d1027e2c150896";
    sha256 = "1ybs5c079w36d39ww3a6x6acwpav3643lhgwvqhh64b8xs3b0bpf";
  };

  NIX_CFLAGS_COMPILE = [
    "-march=armv8-a+crc"
  ];

  preConfigure = ''
    cd armstubs
  '';

  makeFlags = [
    "CC8=${stdenv.cc.targetPrefix}cc"
    "LD8=${stdenv.cc.targetPrefix}ld"
    "OBJCOPY8=${stdenv.cc.targetPrefix}objcopy"
    "OBJDUMP8=${stdenv.cc.targetPrefix}objdump"
    "CC=${stdenv.cc.targetPrefix}cc"
    "LD=${stdenv.cc.targetPrefix}ld"
    "OBJCOPY=${stdenv.cc.targetPrefix}objcopy"
    "OBJDUMP=${stdenv.cc.targetPrefix}objdump"
  ]
  ++ optionals (stdenv.isAarch64) [ "armstub8.bin" "armstub8-gic.bin" ]
  ++ optionals (stdenv.isAarch32) [ "armstub7.bin" "armstub8-32.bin" "armstub8-32-gic.bin" ]
  ;

  installPhase = ''
    mkdir -vp $out/
    cp -v *.bin $out/
  '';

  meta = with stdenv.lib; {
    description = "Firmware related ARM stubs for the Raspberry Pi";
    homepage = https://github.com/raspberrypi/tools;
    license = licenses.bsd3;
    platforms = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ samueldr ];
  };
}
