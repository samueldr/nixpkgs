{ lib
, mkDerivation
, fetchFromGitHub

, fio
, kauth

, cmake
, extra-cmake-modules
, qttools
}:

mkDerivation rec {
  pname = "kdiskmark";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "JonMagon";
    repo = "KDiskMark";
    rev = version;
    sha256 = "09y77xanhizavh463830rk5nb217lwv0i8bhy46nml136l9smkqh";
  };

  buildInputs = [
    kauth
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    qttools
  ];

  qtWrapperArgs = [ ''--prefix PATH : ${lib.makeBinPath [ fio ]}'' ];

  meta = with lib; {
    homepage = "https://github.com/JonMagon/KDiskMark";
    description = "open-source disk benchmark tool for Linux distros";
    maintainers = [ maintainers.samueldr ];
    # Unspecified whether GPLv3 only, or any later version.
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
