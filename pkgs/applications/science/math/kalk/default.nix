{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules
, bison
, flex

, kconfig
, kcoreaddons
, ki18n
, kirigami2
, kunitconversion
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "kalk";
  version = "0.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "kalk";
    rev = "v${version}";
    sha256 = "0x3r3gf9malr611ay4v6nbab8dp2qy82llf8calh5dipidv759h6";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    bison
    flex
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    ki18n
    kirigami2
    kunitconversion
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Calculator built with kirigami";
    homepage = "https://invent.kde.org/plasma-mobile/kalk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
