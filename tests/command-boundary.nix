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
    "omarchy-remove-launcher-entry"
    "omarchy-restart-trackpad"
    "omarchy-system-factory-reset-finish"
    "omarchy-voxtype-install"
  ];
in
pkgs.runCommand "omarchy-command-boundary"
  {
    nativeBuildInputs = [
      pkgs.ripgrep
      pkgs.shellcheck
      runtime
    ];
  }
  ''
    shellcheck ${../packages/overrides}/*

    # The source pin contains 425 command entry points. The curated profile
    # deliberately removes the HEY mail handler, exposing 424. Fail if any
    # other command disappears or a preserved/adapted command regains a direct
    # Arch package, AUR, initramfs, or Limine mutation path.
    test "$(find ${runtime}/share/omarchy/bin -maxdepth 1 -type f -name 'omarchy*' | wc -l)" -eq 424
    test "$(find ${runtime}/bin -maxdepth 1 -type f -name 'omarchy*' | wc -l)" -eq 424
    test "$(rg -l 'is disabled on OmixOS' ${runtime}/share/omarchy/bin/omarchy* | wc -l)" -eq 131
    if rg -n \
      '(^|[;&|[:space:]])(sudo[[:space:]]+)?(pacman[[:space:]]+-[SRU]|yay([[:space:]]|$)|paru([[:space:]]|$)|mkinitcpio([[:space:]]|$)|limine([[:space:]]|$))' \
      ${runtime}/share/omarchy/bin; then
      echo "Arch-mutating command escaped the OmixOS boundary" >&2
      exit 1
    fi

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
    test "$(${runtime}/bin/omarchy-version-channel)" = "nix"
    test "$(${runtime}/bin/omarchy-version-pkgs)" = \
      "not running inside a NixOS system generation"
    ${runtime}/bin/omarchy-theme-set-browser
    test -f ${runtime}/share/applications/foot.desktop
    test -f ${runtime}/share/applications/Linear.desktop
    test -f ${runtime}/share/applications/Slack.desktop
    test ! -e ${runtime}/share/applications/Basecamp.desktop
    test ! -e ${runtime}/share/applications/HEY.desktop
    test ! -e ${runtime}/share/omarchy/bin/omarchy-webapp-handler-hey
    ! grep -Fq 'app.hey.com' ${runtime}/share/omarchy/default/hypr/bindings/applications.lua
    grep -Fxq 'x-scheme-handler/mailto=chromium-browser.desktop' ${runtime}/share/omarchy/default/applications/mimeapps.list
    test -f ${runtime}/share/icons/hicolor/256x256/apps/disk-usage.png
    OMIXOS_DEBUG_LOG="$TMPDIR/omixos-debug.log" ${runtime}/bin/omarchy-debug --no-sudo --print |
      grep -F "OmixOS diagnostics"
    ${runtime}/bin/omarchy-agent-usage-fireworks --limits-only |
      ${pkgs.jq}/bin/jq -e '.id == "fireworks"'

    touch "$out"
  ''
