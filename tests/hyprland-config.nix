{
  pkgs,
  runtime,
}:

pkgs.runCommand "omarchy-hyprland-config"
  {
    nativeBuildInputs = [ pkgs.hyprland ];
  }
  ''
    export HOME="$TMPDIR/home"
    export XDG_RUNTIME_DIR="$TMPDIR/runtime"
    export OMARCHY_PATH=${runtime}/share/omarchy

    mkdir -p "$HOME/.config" "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
    cp -R "$OMARCHY_PATH/config/hypr" "$HOME/.config/hypr"
    chmod -R u+w "$HOME/.config/hypr"

    Hyprland --verify-config --config "$HOME/.config/hypr/hyprland.lua" 2>&1 |
      tee "$TMPDIR/hyprland-verify.log"
    grep -F "config ok" "$TMPDIR/hyprland-verify.log"

    touch "$out"
  ''
