{ stdenv, fetchurl, qt5, pcsclite, gcc, lib, patchelf }:

stdenv.mkDerivation rec {
  name = "eszemelyi-kliens-${version}";
  version = "1.5.19";

  buildInputs = [ pcsclite qt5.qtbase gcc patchelf ];

  src = fetchurl {
    url = "https://eszemelyi.hu/app/eSzemelyi_Kliens_x64_1_5_19.deb";
    sha256 = "0ydx6j824hv9fw5qa00nrwrx6w7rc2q55vk84skq25lwsf1ac2ss";
  };

  sourceRoot = ".";
  bulildPhase = ":";

  unpackCmd = ''
    ar p "$src" data.tar.xz | tar xJ
  '';

  installPhase = ''
    mkdir $out
    rm -rf usr/lib/Qt5
    cp -r usr/lib usr/share $out
    mkdir $out/bin
    ln -sf $out/lib/ESZEMELYI/eszig-cmu $out/bin/eszig-cmu
    ln -sf $out/lib/ESZEMELYI/eszig-eid $out/bin/eszig-eid
  '';

  preFixup = let
    libPath = lib.makeLibraryPath [
      qt5.qtbase
      stdenv.cc.cc.lib
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/eszig-eid

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/eszig-cmu
  '';

  meta = with stdenv.lib; {
    homepage = https://eszemelyi.hu/kartyaolvaso/kartyaolvaso_alkalmazas;
    description = "Card reader for the Hungarian eID (eSzemélyi Kliens) issued by KEKKH";
    license = licenses.eszemelyi-kliens;
    maintainers = [ maintainers.sevcsik ];
    platform = "x86_64-linux";
  };
}
