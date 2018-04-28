{ stdenv, hostPlatform
, fetchurl
, fetchFromGitHub
, linuxManualConfig
, firmwareLinuxNonfree
, bison, flex
, binutils-unwrapped
, kernelPatches ? [] }:

# Inspired by https://github.com/thefloweringash/rock64-nix/blob/master/packages/linux_ayufan_4_4.nix

let
  withAdditionalFirmware = stdenv.mkDerivation rec {
    brcmfmac4356-pcie_txt = fetchurl {
      # FIXME : get a more official source.
      url = "https://raw.githubusercontent.com/andir/nixos-gpd-pocket/master/firmware/brcmfmac4356-pcie.txt";
      sha256 = "1v44f7y8pxqw3xmk2v43ny5lhjg6lpch2alry40pdzq56pnplypi";
    };
    name = "plus-extra--${firmwareLinuxNonfree.name}";
    src = firmwareLinuxNonfree;
    dontBuild = true;
    installPhase = ''
      cp -prf . $out
      cp ${brcmfmac4356-pcie_txt} $out/lib/firmware/brcm/brcmfmac4356-pcie.txt
    '';
  };

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
  postPatch = ''
    patchShebangs .
  '';

in
let
  buildLinux = (args: (linuxManualConfig args).overrideAttrs ({ makeFlags, kernelPatches ? [], ... }: {
    inherit patches postPatch;
  }));

  configfile = stdenv.mkDerivation {
    name = "HAC-linux-kernel-config-4.16";
    inherit version;
    inherit src patches postPatch;
    nativeBuildInputs = [bison flex];

    buildPhase = ''
      make nintendo-switch_defconfig
    '';

    installPhase = ''
      substituteInPlace .config --replace \
        /lib/firmware \
        "${withAdditionalFirmware}/lib/firmware"
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
