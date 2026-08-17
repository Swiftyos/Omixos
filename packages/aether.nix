{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  gtk3,
  webkitgtk_4_1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aether";
  version = "4.28.0";

  src = fetchurl {
    url = "https://github.com/bjarneo/aether/releases/download/v${finalAttrs.version}/aether_${finalAttrs.version}_arm64.deb";
    hash = "sha256-tIyiWY65DimBM82giWX62+rQrBRs9JUyqNt8kPKd2m8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" .
    runHook postUnpack
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R usr/* "$out/"
    runHook postInstall
  '';

  meta = {
    description = "Native Omarchy theme generator";
    homepage = "https://github.com/bjarneo/aether";
    license = lib.licenses.mit;
    platforms = [ "aarch64-linux" ];
    mainProgram = "aether";
  };
})
