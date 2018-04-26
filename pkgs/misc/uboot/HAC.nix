{ lib, buildUBoot, fetchFromGitHub, armTrustedFirmwareHAC }:
let
in buildUBoot rec {
  name = "uboot-${defconfig}-${version}";
  version = "2018.01";

  src = fetchFromGitHub {
    owner = "fail0verflow";
    repo = "switch-u-boot";
    rev = "a2d885d448eacb72085f262f9b28951384a8e678";
    sha256 = "14gym8rcjlhz98s24winlh110857pis6lcbs62wdxc4f1vz4lig6";
  };

  BL31 = "${armTrustedFirmwareHAC}/bl31.bin";

  defconfig = "nintendo-switch_defconfig";
  filesToInstall = [
    "System.map"
    "u-boot-dtb.bin"
    "u-boot-dtb.img"
    "u-boot-elf.o"
    "u-boot-nodtb.bin"
    "u-boot.bin"
    "u-boot.cfg"
    "u-boot.cfg.configs"
    "u-boot.dtb"
    "u-boot.elf"
    "u-boot.img"
    "u-boot.lds"
    "u-boot.map"
    "u-boot.srec"
    "u-boot.sym"
  ];
  #filesToInstall = ["u-boot-sunxi-with-spl.bin"];

  extraMeta = with lib; {
    maintainers = [ maintainers.samueldr ];
    platforms = ["aarch64-linux"];
  };
}
