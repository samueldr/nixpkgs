{ config, lib, pkgs, ... }:

with lib;

let

  dmcfg = config.services.xserver.displayManager;
  ldmcfg = dmcfg.lightdm;
  cfg = ldmcfg.greeters.web;

  inherit (pkgs) stdenv lightdm writeScript writeText;

  theme = cfg.theme.package;
  #icons = cfg.iconTheme.package;

  # The default greeter provided with this expression is the web greeter.
  # Again, we need a few things in the environment for the greeter to run with
  # fonts/icons.
  wrappedWebGreeter = pkgs.runCommand "lightdm-web-greeter"
  # FIXME : Add necessary stuff for webkitgtk2
    { buildInputs = [ pkgs.makeWrapper ]; }
    ''
      # This wrapper ensures that we actually get themes
      makeWrapper ${pkgs.lightdm_web_greeter}/bin/lightdm-webkit2-greeter \
        $out/greeter \
        --prefix PATH : "${pkgs.glibc.bin}/bin" \
        --set GDK_PIXBUF_MODULE_FILE "${pkgs.gdk_pixbuf.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
        --set GTK_PATH "${theme}:${pkgs.gtk3.out}" \
        --set GTK_EXE_PREFIX "${theme}" \
        --set GTK_DATA_PREFIX "${theme}" \
        --set XDG_DATA_DIRS "$#{theme}/share:$#{icons}/share" \
        --set XDG_CONFIG_HOME "${theme}/share"

      cat - > $out/lightdm-web-greeter.desktop << EOF
      [Desktop Entry]
      Name=LightDM Greeter
      Comment=This runs the LightDM Greeter
      Exec=$out/greeter
      Type=Application
      EOF
    '';

  webGreeterConf = writeText "lightdm-web-greeter.conf"
    ''
    [greeter]
    theme-name = ${cfg.theme.name}
      #icon-theme-name = $#{cfg.iconTheme.name}
    background = ${ldmcfg.background}
    '';

in
{
  options = {

    services.xserver.displayManager.lightdm.greeters.web = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable lightdm-web-greeter as the lightdm greeter.
        '';
      };

      # FIXME
      theme = {

        package = mkOption {
          type = types.package;
          default = pkgs.gnome3.gnome_themes_standard;
          defaultText = "pkgs.gnome3.gnome_themes_standard";
          description = ''
            The package path that contains the theme given in the name option.
          '';
        };

        name = mkOption {
          type = types.str;
          default = "Adwaita";
          description = ''
            Name of the theme to use for the lightdm-web-greeter.
          '';
        };

      };

      #iconTheme = {

      #  package = mkOption {
      #    type = types.package;
      #    default = pkgs.gnome3.defaultIconTheme;
      #    defaultText = "pkgs.gnome3.defaultIconTheme";
      #    description = ''
      #      The package path that contains the icon theme given in the name option.
      #    '';
      #  };

      #  name = mkOption {
      #    type = types.str;
      #    default = "Adwaita";
      #    description = ''
      #      Name of the icon theme to use for the lightdm-web-greeter.
      #    '';
      #  };

      #};

    };

  };

  config = mkIf (ldmcfg.enable && cfg.enable) {

    services.xserver.displayManager.lightdm.greeter = mkDefault {
      package = wrappedWebGreeter;
      name = "lightdm-web-greeter";
    };

    environment.etc."lightdm/lightdm-web-greeter.conf".source = webGreeterConf;

  };
}
