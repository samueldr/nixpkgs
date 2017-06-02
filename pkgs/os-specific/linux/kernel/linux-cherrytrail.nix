{ stdenv, fetchFromGitHub, perl, buildLinux, ... } @ args:

assert stdenv.is64bit;

stdenv.lib.overrideDerivation (import ./generic.nix (args // rec {
  version = "4.12.0-rc1";
  extraMeta.branch = "4.12";

  src = fetchFromGitHub {
    owner = "jwrdegoede";
    repo = "linux-sunxi";
    rev = "f7224d6a2ae5f810b646d43169a27d88b088fec7";
    sha256 = "1y49qrrla61fw59cmkkc2ks8chkw13bi8ijv417nxbrfwmgs2vas";
  };

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = true;
  features.netfilterRPFilter = true;
  # Used to choose kernel options in common-config.nix
  # FIXME : Find out if there's a better way.
  features.intelCherrytrail = true;

  extraMeta.hydraPlatforms = [];

})) (oldAttrs: {
  preConfigurePhases = ["mrproperPhase"];
  mrproperPhase = ''
    rm .config
  '';
})
