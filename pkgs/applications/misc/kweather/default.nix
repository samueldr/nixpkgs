{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, ki18n
, kirigami2
, knotifications
, kquickcharts
, plasma-framework
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "kweather";
  version = "0.4";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "${version}";
    sha256 = "1d9rg3bayg307vyd7770dzb9wq1ap7381ssn7mcshii3wsvzngaz";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    ki18n
    kirigami2
    knotifications
    kquickcharts
    plasma-framework
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Weather application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/kweather";
    license = [ licenses.gpl2Plus licenses.cc-by-40 ];
    maintainers = with maintainers; [ samueldr ];
  };
}
