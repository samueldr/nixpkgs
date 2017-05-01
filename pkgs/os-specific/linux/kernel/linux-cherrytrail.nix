{ stdenv, fetchFromGitHub, perl, buildLinux, ... } @ args:

assert stdenv.is64bit;

import ./generic.nix (args // rec {
  version = "4.11.0-rc5";
  extraMeta.branch = "4.11";

  src = fetchFromGitHub {
    #owner = "jwrdegoede";
    #repo = "linux-sunxi";
    # FIXME : Find a way to remove `.config` file without forking.
    # When I override the patch phases weird stuff happens.
    # I might need to jump into a nix-shell to look around and understand.
    owner = "samueldr";
    repo = "linux";
    rev = "d10fb04ff7d4e800ca6c17cf1e1d39ff89f8653d";
    sha256 = "171w7h417j3xw4jlgv9b3wk24pp3534xggi2mahs62m9is7l78rm";
  };

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = true;
  features.netfilterRPFilter = true;
  # Used to choose kernel options in common-config.nix
  # FIXME : Find out if there's a better way.
  features.intelCherrytrail = true;

  extraMeta.hydraPlatforms = [];

} // (args.argsOverride or {}))
