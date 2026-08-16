{ pkgs, runtime }:

pkgs.runCommand "omarchy-runtime-smoke" { nativeBuildInputs = [ pkgs.bash ]; } ''
  export HOME="$TMPDIR/home"
  export XDG_RUNTIME_DIR="$TMPDIR/runtime"
  mkdir -p "$HOME/.config/omarchy/themes" "$XDG_RUNTIME_DIR"

  test "$(${runtime}/bin/omarchy-version)" = \
    "quattro-nixos (30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec)"
  test -f ${runtime}/share/omarchy/shell/shell.qml
  test -f ${runtime}/share/omarchy/default/hypr/omarchy.lua
  test -f ${runtime}/share/omarchy/themes/tokyo-night/colors.toml

  OMARCHY_THEME_HEADLESS=1 ${runtime}/bin/omarchy-theme-set "Tokyo Night"
  test "$(cat "$HOME/.local/state/omarchy/current/theme.name")" = "tokyo-night"
  test -f "$HOME/.local/state/omarchy/current/theme/shell.toml"
  test -f "$HOME/.local/state/omarchy/current/theme/hyprland.lua"

  touch "$out"
''
