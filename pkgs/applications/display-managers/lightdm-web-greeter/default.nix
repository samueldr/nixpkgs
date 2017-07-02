{ stdenv, fetchurl, fetchFromGitHub
, lightdm, pkgconfig, intltool, gettext
, meson, ninja
, hicolor_icon_theme, makeWrapper
, glib, dbus_glib, webkitgtk24x, gobjectIntrospection
, libX11
, gtk3
}:

let
  version = "2.2.5";
  hack_ld = [
    gobjectIntrospection glib gtk3 webkitgtk libX11 dbus_glib lightdm
  ];
in
stdenv.mkDerivation rec {
  name = "lightdm-web-greeter-${version}";

  src = fetchFromGitHub {
    owner = "Antergos";
    repo = "web-greeter";
    rev = "${version}";
    sha256 = "109qvybpwb35sybga7vfhr67w7w15zlx1d2nrhikmhj1miayr3id";
  };

  patches = [
    #
    # Cloned the repo at ~/tmp/lightdm/web-greeter...
    # git diff > /etc/nixos/nixpkgs/pkgs/applications/display-managers/lightdm-web-greeter/test.patch
    # To try to find out what's wrong.
    #
    ./test.patch
    #(fetchurl {
    #  name = "lightdm-gtk-greeter-2.0.1-lightdm-1.19.patch";
    #  url = "https://588764.bugs.gentoo.org/attachment.cgi?id=442616";
    #  sha256 = "0r383kjkvq9yanjc1lk878xc5g8993pjgxylqhhjb5rkpi1mbfsv";
    #})
  ];

  # FIXME : THIS SEEMS WRONG
  LD_LIBRARY_PATH = (stdenv.lib.makeLibraryPath hack_ld);

  buildInputs = [ pkgconfig intltool gettext makeWrapper ]
    ++ [ meson ninja ] ++ hack_ld
    ;

    #  configureFlags = [
    #    "--localstatedir=/var"
    #    "--sysconfdir=/etc"
    #  ] ++ stdenv.lib.optional useGTK2 "--with-gtk2";
    #

  configurePhase = ''
    patchShebangs build/utils.sh
    cd build
    meson --prefix "$out" ..
    mesonconf -Dwith-theme-dir="$out/share/lightdm-webkit/themes"
    mesonconf -Dwith-desktop-dir="$out/share/xgreeters"
    mesonconf -Dwith-webext-dir="$out/lib/lightdm-webkit2-greeter"
    mesonconf -Dwith-locale-dir="$out/share/locale"
    mesonconf -Dwith-config-dir="$out/etc"
  '';

  buildPhase = ''
    ninja
  '';

  installPhase = ''
    ninja install
    wrapProgram $out/bin/lightdm-webkit2-greeter \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH"
  '';

  #  postInstall = ''
  #    #  substituteInPlace "$out/share/xgreeters/lightdm-gtk-greeter.desktop" \
  #    #    --replace "Exec=lightdm-gtk-greeter" "Exec=$out/sbin/lightdm-gtk-greeter"
  #    #  wrapProgram "$out/sbin/lightdm-gtk-greeter" \
  #    #    --prefix XDG_DATA_DIRS ":" "${hicolor_icon_theme}/share"
  #  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/Antergos/web-greeter;
    platforms = platforms.linux;
    license = licenses.gpl3;
    # maintainers = with maintainers; [ samueldr ];
  };
}
