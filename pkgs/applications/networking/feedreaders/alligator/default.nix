{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kconfig
, kcoreaddons
, ki18n
, kirigami2
, qtquickcontrols2
, syndication
}:

mkDerivation rec {
  pname = "alligator";
  version = "0.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "0lhfaai216v95l29gbizc5rxid70gmbzaqh26c7k98f2pmrrv9rs";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    ki18n
    kirigami2
    qtquickcontrols2
    syndication
  ];

  meta = with lib; {
    description = "RSS reader made with kirigami";
    homepage = "https://invent.kde.org/plasma-mobile/alligator";
    # https://invent.kde.org/plasma-mobile/alligator/-/commit/db30f159c4700244532b17a260deb95551045b7a
    #  * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
