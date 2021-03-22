{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcalendarcore
, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, knotifications
, kpeople
, kservice
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "calindori";
  version = "1.4";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "141d5rfcydz5b7i31kfrfhx3kf5gx9phqhk9wd8h3s9mm9cv46zl";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcalendarcore
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    knotifications
    kpeople
    kservice
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Calendar for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/calindori";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
