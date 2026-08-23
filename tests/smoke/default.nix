{ pkgs, runtime }:

pkgs.runCommand "omarchy-runtime-smoke" { nativeBuildInputs = [ pkgs.bash ]; } ''
  export HOME="$TMPDIR/home"
  export XDG_RUNTIME_DIR="$TMPDIR/runtime"
  mkdir -p "$HOME/.config/omarchy/themes" "$XDG_RUNTIME_DIR"

  test "$(${runtime}/bin/omarchy-version)" = \
    "quattro-nixos (f4f3d4c71a0a5c392b20ce05291531881a1b3bfe)"
  test -f ${runtime}/share/omarchy/shell/shell.qml
  test -f ${runtime}/share/omarchy/default/hypr/omarchy.lua
  test -f ${runtime}/share/omarchy/themes/tokyo-night/colors.toml

  # omarchy-launch-about sources this library by PATH lookup; the raw script
  # must resolve ahead of the exec wrapper or sourcing would replace the shell.
  bash -c 'set -e
    PATH=${runtime}/share/omarchy/bin:$PATH
    source omarchy-branding-about-animation
    declare -F sheen_build >/dev/null'

  OMARCHY_THEME_HEADLESS=1 ${runtime}/bin/omarchy-theme-set "Tokyo Night"
  test "$(cat "$HOME/.local/state/omarchy/current/theme.name")" = "tokyo-night"
  test -f "$HOME/.local/state/omarchy/current/theme/shell.toml"
  test -f "$HOME/.local/state/omarchy/current/theme/hyprland.lua"

  # Store-backed theme directories must remain replaceable user state.
  test -w "$HOME/.local/state/omarchy/current/theme/backgrounds"
  OMARCHY_THEME_HEADLESS=1 ${runtime}/bin/omarchy-theme-set Catppuccin
  test "$(cat "$HOME/.local/state/omarchy/current/theme.name")" = "catppuccin"
  test -w "$HOME/.local/state/omarchy/current/theme/backgrounds"

  touch "$out"
''
