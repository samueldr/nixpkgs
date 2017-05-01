{ config, pkgs, ... }:

{
  imports = [ ./installation-cd-graphical-kde.nix ];

  # Use a custom kernel.
  boot.kernelPackages = pkgs.linuxPackages_cherrytrail;

  # We can add xf86videointel as Cherry Trail *will* use it.
  # This will allow backlight control to actually work.
  # FIXME : this does not actually enables the backlight controls...
  environment.systemPackages = with pkgs; [
    xorg.xf86videointel
  ];

  environment.etc = [
    {
      # Disables the mac address randomization
      # The common rtl8723bs wifi module does not play well at boot with it.
      source = pkgs.writeText "30-mac-randomization.conf" ''
        [device-mac-randomization]
        wifi.scan-rand-mac-address=no

        [connection-mac-randomization]
        ethernet.cloned-mac-address=preserve
        wifi.cloned-mac-address=preserve
      '';
      target = "NetworkManager/conf.d/30-mac-randomization.conf";
    }
  ];

  boot.kernelParams = [
    # Useful on some devices
    "fbcon=rotate:1"
    # TODO : Check if needed.
    "tsc=reliable"
    "clocksource=tsc"
    "clocksource_failover=tsc"
  ];
}
