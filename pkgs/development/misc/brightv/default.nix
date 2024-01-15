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
    postBuild = ''
      # Makes library files accessible to the more common `/lib` path.
      (
      cd $out/lib
      for f in i386e2/*; do
        ln -vs "$f"
      done
      )
    '';
  };
}
