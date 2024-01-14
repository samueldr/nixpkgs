{ stdenvNoCC
, fetchzip
#, brightv-linux
#, binutils
#, perl
}:

let
  # XXX split the package in discrete derivations for the bare tree and the fixed-up tools
  brightv-linux = "BV.LINUX";
  perl = "PERL";
  binutils = "BINUTILS";
in

stdenvNoCC.mkDerivation {
  pname = "brightv.common";
  version = "4";
  outputs = [ "out" "samples" ];
  src = fetchzip {
    url = "http://www.chokanji.com/archive/brightv.common.tar.gz";
    hash = "sha256-h+UVRFwixW56BDCkH2y0Of5LvvEypmS8ieJTeKsZDfw=";
    stripRoot = false;
  };

  patches = [
    ./0001-driver-etc-makerules-Fix.patch
    ./0001-appl-sample2-Don-t-use-install-dir-for-transitory-bu.patch
  ];

  # NOTE: `bin` folder empty and skipped
  # NOTE: `spec` folder contains only a broken encoding manpage for `gterm`.
  buildPhase = ''
    mkdir -vp $samples
    mkdir -vp $out

    # Actual platform-independent SDK bits
    mv -v -t $out etc lib include unix

    (
      cd $out/etc
      for f in chkundef makedeps mkimport wch2hex; do
        sed -i 'i#!${perl}/bin/perl' "$f"
      done

      substituteInPlace makerules \
        --replace 'PATH = .' "" \
        --replace 'CPP = /lib/cpp' 'CPP = $(GNUi386)/bin/cpp' \
        --replace '$(BD)/etc/backup_copy' 'true' \
        --replace '$(BD)/etc/bzcomp' '${brightv-linux}/bin/bzcomp' \
        --replace '$(BD)/etc/mkbtf' '${brightv-linux}/bin/mkbtf' \
        --replace '$(BD)/etc/databox' '${brightv-linux}/bin/databox'

      PROGS=(
        addr2line
        ar
        as
        c++filt
        dwp
        elfedit
        gprof
        ld
        ld.bfd
        ld.gold
        nm
        objcopy
        objdump
        ranlib
        readelf
        size
        strings
        strip
      )

      for PROG in ''${PROGS[@]}; do
        substituteInPlace makerules \
          --replace '$(GNUi386)/bin/'"$PROG" "${binutils}/bin/i386-unknown-gnu-$PROG"
      done
    )

    # The misc. makefile includes and helpers data is part of the SDK.
    for d in appl driver util; do
      mkdir -p $out/$d
      mv -vt $out/$d/ $d/etc
    done
    mv -vt $out/appl/ appl/dbox

    # Only sample files are copied over
    mv -v -t $samples appl driver util
    # Fixup SDK path in samples
    echo ":: Fixing up SDK include path"
    (cd $samples
      for d in appl driver util; do
        for f in "$d"/*/src/Makefile; do
          printf " -> %s\n" "$f"
          substituteInPlace "$f" --replace 'include ../../etc/makerules' "include $out/$d/etc/makerules"
        done
      done
    )
  '';
}
