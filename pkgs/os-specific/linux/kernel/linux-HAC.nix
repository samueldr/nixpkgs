{ stdenv, hostPlatform
, fetchFromGitHub
, linuxManualConfig
, bison, flex
, binutils-unwrapped
, kernelPatches ? [] }:

# Inspired by https://github.com/thefloweringash/rock64-nix/blob/master/packages/linux_ayufan_4_4.nix

let
  src = fetchFromGitHub {
    owner = "fail0verflow";
    repo = "switch-linux";
    rev = "01b404c2112028a48ccf533b84218689032054c3";
    sha256 = "1x7bvc69rhnkx3cy4djsjk0hrc6ypdsnm3465v1gxmddd3fx1mjb";
  };
  version = "4.16.0-rc1";
in

let
  buildLinux = (args: (linuxManualConfig args).overrideAttrs ({ makeFlags, ... }: {
    # Necessary?
    postPatch = ''
      patchShebangs .
    '';
    makeFlags = makeFlags ++ [
      # Why do I have to do this??
      "OBJCOPY=${binutils-unwrapped}/bin/${stdenv.cc.targetPrefix}objcopy"
      "AR=${binutils-unwrapped}/bin/${stdenv.cc.targetPrefix}ar"
    ];
  }));

  configfile = stdenv.mkDerivation {
    name = "HAC-linux-kernel-config-4.16";
    inherit version;
    inherit src;
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

# { stdenv, buildPackages, hostPlatform, fetchFromGitHub, perl, buildLinux, ... } @ args:
# 
# buildLinux (args // {
# 
#   kernelPatches = args.kernelPatches;
# 
#   features.iwlwifi = true;
#   features.efiBootStub = false;
#   features.needsCifsUtils = true;
#   features.netfilterRPFilter = true;
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
