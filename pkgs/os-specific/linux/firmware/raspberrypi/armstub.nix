{ stdenv, fetchFromGitHub }:

let
  # BINS=armstub.bin armstub7.bin armstub8-32.bin armstub8-32-gic.bin armstub8.bin armstub8-gic.bin
  targets = {
    "armv6l-linux" = "armstub.bin";
    "armv7l-linux" = "armstub7.bin armstub8-32.bin armstub8-32-gic.bin";
    "aarch64-linux" = "armstub8.bin armstub8-gic.bin";
  }.${stdenv.hostPlatform.system} or (throw "raspberrypi-armstub not supported on '${stdenv.hostPlatform.system}'");
in
stdenv.mkDerivation rec {
  name = "raspberrypi-armstub-${version}";
  version = "2019-05-09";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "tools";
    rev = "49719d5544cd33b8c146235e1420f68cd92420fe";
    sha256 = "1qmiajz0qp15ysy9s9hi4ll5qi3rwc3m06hsncqyja6virdz1pn8";
  };

  nativeBuildInputs = [ ];

  buildPhase = ''
    export CC8="$CC"
    export LD8="$LD"
    export OBJCOPY8="$OBJCOPY"
    export OBJDUMP8="$OBJDUMP"

    cd armstubs
    make ${targets}
  '';

  installPhase = ''
    mkdir -p "$out/"
    cp ${targets} "$out/"

  '';

  meta = with stdenv.lib; {
    description = "Raspberry Pi ARM stubs";
    homepage = https://github.com/raspberrypi/tools;
    license = licenses.unfreeRedistributable;
    platforms = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ samueldr ];
  };
}
