{
  lib,
  stdenvNoCC,
  omarchy-runtime,
}:

stdenvNoCC.mkDerivation {
  pname = "omarchy-fonts";
  inherit (omarchy-runtime) version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm0444 \
      ${omarchy-runtime}/share/omarchy/default/fonts/omarchy/omarchy.ttf \
      "$out/share/fonts/truetype/omarchy/omarchy.ttf"

    runHook postInstall
  '';

  meta = {
    description = "Omarchy icon font used by the quattro Quickshell UI";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
