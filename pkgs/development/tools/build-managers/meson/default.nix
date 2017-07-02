#{ lib, python3Packages, fetchurl }:
#python3Packages.buildPythonPackage rec {
#  version = "0.35.0";
#  name = "meson-${version}";
#
#  src = fetchurl {
#    url = "mirror://pypi/m/meson/${name}.tar.gz";
#    sha256 = "0w4vian55cwcv2m5qzn73aznf9a0y24cszqb7dkpahrb9yrg25l3";
#  };
#
#  meta = with lib; {
#    homepage = http://mesonbuild.com;
#    description = "SCons-like build system that use python as a front-end language and Ninja as a building backend";
#    license = licenses.asl20;
#    maintainers = with maintainers; [ mbe rasendubi ];
#    platforms = platforms.all;
#  };
#}

{ lib, python3Packages }:
python3Packages.buildPythonApplication rec {
  version = "0.40.0";
  pname = "meson";
  name = "${pname}-${version}";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1hb6y5phzd5738rlpz78w8hfzk7sbxj81551mb7bbkkqz8ql1gjw";
  };

  postFixup = ''
    pushd $out/bin
    # undo shell wrapper as meson tools are called with python
    for i in *; do
      mv ".$i-wrapped" "$i"
    done
    popd
  '';

  meta = with lib; {
    homepage = http://mesonbuild.com;
    description = "SCons-like build system that use python as a front-end language and Ninja as a building backend";
    license = licenses.asl20;
    maintainers = with maintainers; [ mbe rasendubi ];
    platforms = platforms.all;
  };
}
