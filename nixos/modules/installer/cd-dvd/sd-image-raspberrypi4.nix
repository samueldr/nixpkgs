# To build, use:
# nix-build nixos -I nixos-config=nixos/modules/installer/cd-dvd/sd-image-raspberrypi4.nix -A config.system.build.sdImage
{ config, lib, pkgs, ... }:

{
  imports = [ ./sd-image-aarch64.nix ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  sdImage = {
    # Reserve far more space still, just in case.
    firmwareSize = 128;

    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        [pi3]
        kernel=u-boot-rpi3.bin

        [pi4]
        kernel=u-boot-rpi4.bin
        enable_gic=1
        armstub=armstub8-gic.bin

        [all]
        # Boot in 64-bit mode.
        arm_64bit=1

        # U-Boot needs this to work, regardless of whether UART is actually used or not.
        # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
        # a requirement in the future.
        enable_uart=1

        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1
      '';
      in
        # This is *in addition* to the sd image aarch64 populateFirmwareCommands
        lib.mkAfter ''
        # Overwrite the existing config.txt
        cp -f ${configTxt} firmware/config.txt

        # Add pi4 specific files
        cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
        cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin

        # Used by u-boot
        cp ${pkgs.linux_rpi4}/dtbs/broadcom/bcm2711-rpi-4-b.dtb firmware/
      '';
  };

  # the installation media is also the installation target,
  # so we don't want to provide the installation configuration.nix.
  installer.cloneConfig = false;
}
