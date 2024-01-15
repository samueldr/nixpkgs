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

  hello = callPackage (
    { stdenv }:

    stdenv.mkDerivation {
      pname = "hello";
      dontUnpack = true;
      version = "0";
      buildPhase = ''
        cat > hello.c <<EOF
        #include <stdio.h>
        int main() {
          printf("Hello, from a Nixpkgs-managed cross-compiler!\n");
          return 0;
        }
        EOF
        (PS4=" $ "; set -x
        "$CC" -o hello hello.c
        )
      '';
      installPhase = ''
        mkdir -vp $out/bin
        cp -vt $out/bin hello
      '';
    }
    ) {
      stdenv = callPackage ({ gcc49Stdenv }: gcc49Stdenv) {};
    };
}
