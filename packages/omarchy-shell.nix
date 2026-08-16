{
  lib,
  stdenvNoCC,
  makeWrapper,
  quickshell,
  omarchy-runtime,
}:

stdenvNoCC.mkDerivation {
  pname = "omarchy-shell";
  inherit (omarchy-runtime) version;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/share/omarchy"
    ln -s ${omarchy-runtime}/share/omarchy/shell "$out/share/omarchy/shell"

    makeWrapper ${omarchy-runtime}/share/omarchy/bin/omarchy-launch-shell "$out/bin/omarchy-shell-session" \
      --set OMARCHY_PATH ${omarchy-runtime}/share/omarchy \
      --prefix PATH : ${
        lib.makeBinPath [
          quickshell
          omarchy-runtime
        ]
      }
  '';

  passthru = {
    inherit quickshell;
    runtime = omarchy-runtime;
  };

  meta = {
    description = "Current Omarchy quattro Quickshell desktop";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
