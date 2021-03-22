{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcontacts
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, knotifications
, kpeople
, libphonenumber
, libpulseaudio
, protobuf
, qtquickcontrols2
, telepathy
}:

mkDerivation rec {
  pname = "plasma-dialer";
  version = "0.3";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "10bxl6zxn3s530l27d7w9ln7j0qwvgkx9s7gyqanx9csfl1w53px";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcontacts
    kcoreaddons
    kdbusaddons
    ki18n
    kirigami2
    knotifications
    kpeople
    libphonenumber
    libpulseaudio
    protobuf # Needed by libphonenumber
    qtquickcontrols2
    telepathy
  ];

  meta = with lib; {
    description = "Dialer for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-dialer";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
