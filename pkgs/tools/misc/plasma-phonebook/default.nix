{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kcontacts
, kcoreaddons
, kirigami2
, kpeople
, kpeoplevcard
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "plasma-phonebook";
  version = "0.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "0n1kziwahx5dpciz45vr5jir4ysk6ldy6cn9r76m7rfgnkn0217w";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kcontacts
    kcoreaddons
    kirigami2
    kpeople
    kpeoplevcard
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Phone book for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-phonebook";
    # https://invent.kde.org/plasma-mobile/plasma-phonebook/-/commit/3ac27760417e51c051c5dd44155c3f42dd000e4f
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
