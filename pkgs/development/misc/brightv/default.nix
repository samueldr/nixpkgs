{ callPackage
, symlinkJoin
}:

rec {
  sdk-common = callPackage ./brightv-common { };
  sdk-linux-headers = callPackage ./brightv-linux-headers { };
  sdk-libc = symlinkJoin {
    name = "brightv-libc-${sdk-common.version}";
    paths = [
      sdk-common.out
      sdk-linux-headers.out
    ];
  };
}
