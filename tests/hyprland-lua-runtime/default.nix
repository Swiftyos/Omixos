{
  pkgs,
  runtime,
}:

# Execute the omarchy Hyprland Lua config through a full simulated session
# against a strict mock of the Lua API surface extracted from the pinned
# Hyprland's own source. `Hyprland --verify-config` runs headless, where
# hl.get_active_monitor() returns nil and every monitor-dependent code path
# early-returns, so it can only ever prove the config parses. This check runs
# the paths a real session runs: monitor hotplug events, timer bodies, focus
# hops, reloads with a live monitor, and monitor expiry. Config code touching
# API the shipped compositor does not register fails here with the same
# "attempt to call/index a nil value" a user would see in the red error bar.
#
# The surface is regenerated from pkgs.hyprland.src on every build, so a
# Hyprland version change is automatically reflected; if upstream restructures
# its Lua sources the extractor fails loudly instead of passing silently.
pkgs.runCommand "omarchy-hyprland-lua-runtime"
  {
    nativeBuildInputs = [
      pkgs.lua5_4
      pkgs.python3
    ];
    hyprlandSrc = pkgs.hyprland.src;
  }
  ''
    export HOME="$TMPDIR/home"
    export OMARCHY_PATH=${runtime}/share/omarchy
    export HL_SURFACE="$TMPDIR/surface.lua"

    python3 ${./.}/extract-surface.py "$hyprlandSrc" "$HL_SURFACE"

    # Mirror the home-manager first-boot seeding: user Hyprland config, the
    # writable toggle directory, and a staged current theme.
    mkdir -p "$HOME/.config" \
      "$HOME/.local/state/omarchy/toggles/hypr" \
      "$HOME/.local/state/omarchy/current"
    cp -R "$OMARCHY_PATH/config/hypr" "$HOME/.config/hypr"
    chmod -R u+w "$HOME/.config/hypr"
    cp "$OMARCHY_PATH"/default/hypr/toggles/*.lua \
      "$HOME/.local/state/omarchy/toggles/hypr/" 2>/dev/null || true
    printf 'tokyo-night\n' > "$HOME/.local/state/omarchy/current/theme.name"
    cp -R "$OMARCHY_PATH/themes/tokyo-night" "$HOME/.local/state/omarchy/current/theme"
    chmod -R u+w "$HOME/.local/state/omarchy/current/theme"

    # The dictation bindings only register while a voxtype binary is on PATH;
    # stub one in so their code paths are exercised too.
    mkdir -p "$TMPDIR/bin"
    printf '#!/bin/sh\nexit 0\n' > "$TMPDIR/bin/voxtype"
    chmod +x "$TMPDIR/bin/voxtype"
    export PATH="$TMPDIR/bin:$PATH"

    lua ${./.}/run.lua | tee "$TMPDIR/report.txt"
    grep -F "full simulated session ran clean" "$TMPDIR/report.txt"

    touch "$out"
  ''
