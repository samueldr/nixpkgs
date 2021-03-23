{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules

, kauth
, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kitemmodels
, plasma-framework
}:

mkDerivation rec {
  pname = "plasma-settings";
  version = "0.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "v${version}";
    sha256 = "0wlhh1jjz7m5lg26kfql0nwfav0krdd2zqh57dlx5q8cmqfzmmha";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    kauth
    kconfig
    kcoreaddons
    kdbusaddons
    ki18n
    kitemmodels
    plasma-framework
  ];

  meta = with lib; {
    description = "Settings application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-settings";
    # https://invent.kde.org/plasma-mobile/plasma-settings/-/commit/a59007f383308503e59498b3036e1483bca26e35
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
