{
  lib,
  stdenvNoCC,
  makeWrapper,
  quickshell,
  omarchy-runtime,
  qt6Packages,
}:

stdenvNoCC.mkDerivation {
  pname = "omarchy-shell";
  inherit (omarchy-runtime) version;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/share/omarchy"
    ln -s ${omarchy-runtime}/share/omarchy/shell "$out/share/omarchy/shell"

    # Theme backgrounds ship as webp since upstream migration 1787133200
    # ("Add webp decoding to the shell"); Qt only decodes webp through the
    # qtimageformats plugin, which quickshell's own closure does not carry.
    makeWrapper ${omarchy-runtime}/share/omarchy/bin/omarchy-launch-shell "$out/bin/omarchy-shell-session" \
      --set OMARCHY_PATH ${omarchy-runtime}/share/omarchy \
      --prefix QT_PLUGIN_PATH : "${qt6Packages.qtimageformats}/${qt6Packages.qtbase.qtPluginPrefix}" \
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
