{ lib
, mkDerivation
, fetchFromGitLab

, cmake
, extra-cmake-modules
, wrapGAppsHook

, gst-plugins-bad
, gst-plugins-base
, gst-plugins-good
, gstreamer
, kconfig
, kcoreaddons
, ki18n
, kirigami2
, qtmultimedia
, qtquickcontrols2
}:

mkDerivation rec {
  pname = "plasma-camera";
  # The last tagged version is more than a year old and slightly broken
  version = "2021-03-02";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = pname;
    rev = "d09ec725a6e89128d72c2c58d1a433744a867733";
    sha256 = "082j4xvbx1y7glziwsc3zlvgixhs7pnfbac9lqjdn0kjibycy12b";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapGAppsHook
  ];

  buildInputs = [
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gstreamer

    kconfig
    kcoreaddons
    ki18n
    kirigami2
    qtmultimedia
    qtquickcontrols2
  ];

  meta = with lib; {
    description = "Camera application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-camera";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ samueldr ];
  };
}
