{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  pname = "lci-ldx9000";
  version = "1.11";
  name = "${pname}-${version}-${kernel.version}";

  src = fetchFromGitHub {
    owner = "samueldr-wip";
    repo = "lci_ldx9000_driver";
    rev = "39c88a91db1055142ca9ee0b5a3d8b91b4707a21";
    hash = "sha256-d90Egt6v4RIYLV75dr9PoVF55NhB5Bs3DqNfMIAlOvI=";
  };

  #hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D usblcpd.ko $out/lib/modules/${kernel.modDirVersion}/misc/usblcpd.ko
    install -D testlcpd $out/libexec/testlcpd
  '';

  meta = with lib; {
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
  };
}
