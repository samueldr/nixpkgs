{ stdenv
, fetchFromGitHub
, openssl
}:

stdenv.mkDerivation rec {
  name = "meson-tools-${version}";
  version = "unstable-2017-05-01";

  src = fetchFromGitHub {
    owner = "afaerber";
    repo = "meson-tools";
    rev = "5e01cbadc6f6f21ad88a63492a83182fc4b19d37";
    sha256 = "1bvshfa9pa012yzdwapi3nalpgcwmfq7d3n3w3mlr357a6kq64qk";
  };

  buildInputs = [ openssl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    for b in amlbootsig unamlbootsig amlinfo; do
      cp $b $out/bin/
    done

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    homepage = https://github.com/afaerber/meson-tools;
    description = "Tools for Amlogic Meson ARM platforms";
    license = licenses.gpl2;
    maintainers = with maintainers; [ samueldr ];
  };
}
