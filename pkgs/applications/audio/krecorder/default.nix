{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, ki18n
, kirigami2
, qtmultimedia
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "krecorder";
  version = "0.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "09hw35280c772qc33agjvjdkvmcrf63q3lvl8ax4s3m1s5n8a791";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    ki18n
    kirigami2
    qtmultimedia
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Audio recorder for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/krecorder";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
