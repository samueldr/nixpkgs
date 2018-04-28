{ stdenv, hostPlatform
, fetchFromGitHub
, linuxManualConfig
, bison, flex
, binutils-unwrapped
, kernelPatches ? [] }:

# Inspired by https://github.com/thefloweringash/rock64-nix/blob/master/packages/linux_ayufan_4_4.nix

let
  version = "4.16.0-rc1";
  src = fetchFromGitHub {
    owner = "fail0verflow";
    repo = "switch-linux";
    rev = "01b404c2112028a48ccf533b84218689032054c3";
    sha256 = "1x7bvc69rhnkx3cy4djsjk0hrc6ypdsnm3465v1gxmddd3fx1mjb";
  };
  patches = [
    ./HAC-uncross.diff
    ./HAC-sdhci-voltage.patch
  ];

in
let
  buildLinux = (args: (linuxManualConfig args).overrideAttrs ({ makeFlags, kernelPatches ? [], ... }: {
    postPatch = ''
      patchShebangs .
    '';
    inherit patches;
  }));

  configfile = stdenv.mkDerivation {
    name = "HAC-linux-kernel-config-4.16";
    inherit version;
    inherit src patches;
    nativeBuildInputs = [bison flex];

    buildPhase = ''
      make nintendo-switch_defconfig
    '';

    installPhase = ''
      cp .config $out
    '';
  };

in

buildLinux {
  inherit stdenv kernelPatches;
  inherit hostPlatform;
  inherit src;
  inherit version;

  modDirVersion = "4.16.0-rc1";

  inherit configfile;

  allowImportFromDerivation = true;
}

#{ stdenv, buildPackages, hostPlatform, fetchFromGitHub, perl, buildLinux, ... } @ args:
#let
#  src = fetchFromGitHub {
#    owner = "fail0verflow";
#    repo = "switch-linux";
#    rev = "01b404c2112028a48ccf533b84218689032054c3";
#    sha256 = "1x7bvc69rhnkx3cy4djsjk0hrc6ypdsnm3465v1gxmddd3fx1mjb";
#  };
#  #src = fetchFromGitHub {
#  #  owner = "torvalds";
#  #  repo = "linux";
#  #  rev = "v4.16-rc1";
#  #  sha256 = "0pckpg0xgmcn4a3ig1z8p3vrw9kzf9psa1f4z0aq6n5w91sw1m87";
#  #};
#  version = "4.16.0-rc1";
#in
#
# buildLinux (args // {
#   inherit version;
#   inherit src;
# 
#   kernelPatches = args.kernelPatches;
# 
#   features.iwlwifi = true;
#   features.efiBootStub = false;
#   features.needsCifsUtils = true;
#   features.netfilterRPFilter = true;
#     #enableParallelBuilding = false;
#
# 
# #  # https://github.com/NixOS/nixpkgs/issues/35166#issuecomment-366594016
# #  # override aarch64-multiplatform settings.
# #  # not the right way to do this; need advice.
# #  hostPlatform = hostPlatform // {
# #    platform = hostPlatform.platform // {
# #      kernelBaseConfig = "nintendo-switch_defconfig";
# #      kernelAutoModules = false; # compilation failures otherwise
# #    };
# #  };
# 
# } // (args.argsOverride or {}))
