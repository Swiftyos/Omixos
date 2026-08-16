{ pkgs, runtime }:

let
  blockedCommands = [
    "omarchy-brightness-display-apple"
    "omarchy-dev-status"
    "omarchy-drive-password"
    "omarchy-menu-timezone"
    "omarchy-pkg-add"
    "omarchy-plymouth-set"
    "omarchy-reinstall"
    "omarchy-system-factory-reset-finish"
    "omarchy-voxtype-install"
  ];
in
pkgs.runCommand "omarchy-command-boundary"
  {
    nativeBuildInputs = [
      pkgs.shellcheck
      runtime
    ];
  }
  ''
    shellcheck ${../packages/overrides}/*

    for command in ${pkgs.lib.escapeShellArgs blockedCommands}; do
      set +e
      output="$(${runtime}/bin/"$command" 2>&1)"
      status=$?
      set -e

      test "$status" -eq 2
      grep -F "disabled on OmixOS" <<<"$output"
    done

    ${runtime}/bin/omarchy-update | grep -F "NixOS generation updates"
    set +e
    update_available="$(${runtime}/bin/omarchy-update-available)"
    update_status=$?
    set -e
    test "$update_status" -eq 1
    test "$update_available" = "OmixOS is pinned by flake.lock"
    test "$(${runtime}/bin/omarchy-version)" = \
      "quattro-nixos (30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec)"
    test -f ${runtime}/share/applications/foot.desktop
    test -f ${runtime}/share/icons/hicolor/256x256/apps/disk-usage.png
    OMIXOS_DEBUG_LOG="$TMPDIR/omixos-debug.log" ${runtime}/bin/omarchy-debug --no-sudo --print |
      grep -F "OmixOS diagnostics"
    ${runtime}/bin/omarchy-agent-usage-fireworks --limits-only |
      ${pkgs.jq}/bin/jq -e '.id == "fireworks"'

    touch "$out"
  ''
