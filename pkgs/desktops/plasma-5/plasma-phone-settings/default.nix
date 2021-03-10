{ stdenv, lib, fetchFromGitLab }:
# Using stdenv here is not an error.
# The source for this "package" is not part of srcs.nix

stdenv.mkDerivation {
  pname = "plasma-phone-settings";
  version = "2021-03-04";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "plasma-phone-settings";
    rev = "256f0f276c566f33e0283ebc0d9b97537f6e0593"; # Tip of master
    sha256 = "1ac2f2c1v7562agm2nzr7brlnmdc8k1bpandbms0cnlrsz5cw2nl";
  };

  installPhase = ''
    mkdir -p $out/etc/xdg
    cp etc/xdg/{kdeglobals,kwinrc} $out/etc/xdg
  '';

  meta = {
    description = "Configuration files for Plasma Mobile deployments";
    licenses = []; # FIXME: confirm with upstream that it is the same as Plasma
    maintainers = with lib.maintainers; [ samueldr ];
  };
}
