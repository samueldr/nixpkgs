{ stdenv, fetchFromGitHub, perl, buildLinux, ... } @ args:

assert stdenv.is64bit;

stdenv.lib.overrideDerivation (import ./generic.nix (args // rec {
  version = "4.12.0-rc5";
  extraMeta.branch = "4.12";

  src = fetchFromGitHub {
    owner = "jwrdegoede";
    repo = "linux-sunxi";
    rev = "86d3fac25d8556b18b72195a218365bb6c447a9f";
    sha256 = "0bb3mbx6mf1azbcd6z3l5jsrkczwi45ykhhm3jpv6zfjgab2m4vk";
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
