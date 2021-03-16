{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, knotifications
, plasma-framework
, qtmultimedia
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "kclock";
  version = "0.4.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "kclock";
    rev = "v${version}";
    sha256 = "15kwwx9wmmzi95k3q7kbwx9k0z49ym1yq8nanaiyzk39irqq4z49";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    knotifications
    plasma-framework
    qtmultimedia
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Clock app for plasma mobile";
    homepage = "https://invent.kde.org/plasma-mobile/kclock";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
