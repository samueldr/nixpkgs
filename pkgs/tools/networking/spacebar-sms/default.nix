{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcontacts
, ki18n
, kirigami2
, knotifications
, kpeople
, telepathy
}:

mkDerivation rec {
  pname = "spacebar";
  version = "0.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "11mry27k05h839wn0q3mni62j8x2blzj5ffqrpcwcr5n4q2bib15";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcontacts
    ki18n
    kirigami2
    knotifications
    kpeople
    telepathy
  ];

  meta = with lib; {
    description = "SMS application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/spacebar";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
