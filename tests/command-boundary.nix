{ pkgs, runtime }:

let
  # These are the only source entry points without a faithful NixOS/AArch64
  # implementation. Each is tied to absent Pi hardware, an x86-only runtime,
  # Arch package development, a non-NixOS boot splash, or destructive factory
  # provisioning. The test below proves no unlisted command shares this body.
  boundaryCommands = [
    "omarchy-brightness-display-apple"
    "omarchy-dev-install-ydoo"
    "omarchy-dev-link"
    "omarchy-dev-pkg-test"
    "omarchy-dev-status"
    "omarchy-dev-unlink"
    "omarchy-drive-password"
    "omarchy-hibernation-remove"
    "omarchy-hibernation-setup"
    "omarchy-install-gaming-battlenet"
    "omarchy-install-service-nordvpn"
    "omarchy-install-service-once"
    "omarchy-plymouth-current"
    "omarchy-plymouth-list"
    "omarchy-plymouth-preview"
    "omarchy-plymouth-reset"
    "omarchy-plymouth-set"
    "omarchy-plymouth-set-by-theme"
    "omarchy-plymouth-switcher"
    "omarchy-refresh-plymouth"
    "omarchy-remove-gaming-battlenet"
    "omarchy-remove-gaming-minecraft"
    "omarchy-remove-security-fido2"
    "omarchy-remove-security-fingerprint"
    "omarchy-restart-trackpad"
    "omarchy-setup-security-fido2"
    "omarchy-setup-security-fingerprint"
    "omarchy-system-factory-reset"
    "omarchy-system-factory-reset-finish"
    "omarchy-toggle-hybrid-gpu"
    "omarchy-windows-vm"
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
    shellcheck ${../packages/overrides}/omarchy-*

    # The source pin contains 433 command entry points. The curated profile
    # deliberately removes the HEY handler and adds omarchy-pkg-list plus the
    # OmixOS display autodetection command omarchy-hw-autoscale, for 434.
    # Fail if any command disappears or a preserved/adapted command regains a
    # direct Arch package, AUR, initramfs, or Limine path.
    test "$(find ${runtime}/share/omarchy/bin -maxdepth 1 -type f -name 'omarchy*' | wc -l)" -eq 434
    test "$(find ${runtime}/bin -maxdepth 1 -type f -name 'omarchy*' | wc -l)" -eq 434
    boundary_hash="$(sha256sum ${runtime}/share/omarchy/bin/omarchy-brightness-display-apple | cut -d' ' -f1)"
    test "$(sha256sum ${runtime}/share/omarchy/bin/omarchy* | awk -v hash="$boundary_hash" '$1 == hash { count++ } END { print count + 0 }')" -eq ${toString (builtins.length boundaryCommands)}
    for command in ${pkgs.lib.escapeShellArgs boundaryCommands}; do
      test "$(sha256sum ${runtime}/share/omarchy/bin/"$command" | cut -d' ' -f1)" = "$boundary_hash"
    done
    if rg -n \
      '(^|[;&|[:space:]])(sudo[[:space:]]+)?(pacman[[:space:]]+-[SRU]|yay([[:space:]]|$)|paru([[:space:]]|$)|mkinitcpio([[:space:]]|$)|limine([[:space:]]|$))' \
      ${runtime}/share/omarchy/bin; then
      echo "Arch-mutating command escaped the OmixOS boundary" >&2
      exit 1
    fi

    for command in ${pkgs.lib.escapeShellArgs boundaryCommands}; do
      set +e
      output="$(${runtime}/bin/"$command" 2>&1)"
      status=$?
      set -e

      test "$status" -eq 2
      grep -F "disabled on OmixOS" <<<"$output"
    done

    # Menu guards and every public package path use the pinned Nix user
    # profile rather than pretending Pacman exists.
    grep -Fq 'omarchy-pkg-list' ${runtime}/share/omarchy/shell/plugins/menu/MenuModel.js
    ! grep -Fq 'pacman -Qq' ${runtime}/share/omarchy/shell/plugins/menu/MenuModel.js
    grep -Fq 'github:NixOS/nixpkgs/' ${runtime}/share/omarchy/bin/omarchy-pkg-add
    ! grep -Fq 'is disabled on OmixOS' ${runtime}/share/omarchy/bin/omarchy-pkg-add
    ! grep -Fq 'is disabled on OmixOS' ${runtime}/share/omarchy/bin/omarchy-pkg-install
    ! grep -Fq 'is disabled on OmixOS' ${runtime}/share/omarchy/bin/omarchy-remove-launcher-entry
    ! grep -Fq 'is disabled on OmixOS' ${runtime}/share/omarchy/bin/omarchy-voxtype-install

    # Proprietary desktop apps with no AArch64 binary retain the same menu
    # lifecycle as browser-backed apps and are removable from user state.
    test_home="$TMPDIR/webapp-home"
    mkdir -p "$test_home"
    HOME="$test_home" XDG_STATE_HOME="$test_home/.local/state" \
      ${runtime}/bin/omarchy-pkg-add openai-codex-desktop spotify dropbox
    test -f "$test_home/.local/share/applications/ChatGPT.desktop"
    test -f "$test_home/.local/share/applications/Spotify.desktop"
    test -f "$test_home/.local/share/applications/Dropbox.desktop"
    HOME="$test_home" XDG_STATE_HOME="$test_home/.local/state" \
      ${runtime}/bin/omarchy-pkg-present openai-codex-desktop spotify dropbox
    HOME="$test_home" XDG_STATE_HOME="$test_home/.local/state" \
      ${runtime}/bin/omarchy-pkg-drop openai-codex-desktop spotify dropbox
    test ! -e "$test_home/.local/share/applications/ChatGPT.desktop"
    test ! -e "$test_home/.local/share/applications/Spotify.desktop"
    test ! -e "$test_home/.local/share/applications/Dropbox.desktop"

    HOME="$TMPDIR/update-home" OMIXOS_HOST=pi4 ${runtime}/bin/omarchy-update --dry-run |
      grep -F "nixos-rebuild switch"
    HOME="$TMPDIR/update-home" OMIXOS_HOST=pi4 ${runtime}/bin/omarchy-update --dry-run |
      grep -F "nix flake update --flake"
    set +e
    update_available="$(HOME="$TMPDIR/update-home" OMIXOS_UPDATE_CHECK_OFFLINE=1 ${runtime}/bin/omarchy-update-available)"
    update_status=$?
    set -e
    test "$update_status" -eq 1
    test "$update_available" = "OmixOS update check skipped offline"
    OMIXOS_DEV_ENV_DRY_RUN=1 ${runtime}/bin/omarchy-install-dev-env node |
      grep -F 'mise use --global node@latest'
    OMIXOS_DEV_ENV_DRY_RUN=1 ${runtime}/bin/omarchy-remove-dev-env node |
      grep -F 'mise uninstall node --all'
    OMIXOS_NETWORK_DRY_RUN=1 ${runtime}/bin/omarchy-dns Cloudflare |
      grep -F 'ipv4=1.1.1.1 1.0.0.1'
    OMIXOS_SYSTEM_DRY_RUN=1 ${runtime}/bin/omarchy-menu-timezone Europe/Madrid |
      grep -Fx 'timezone=Europe/Madrid'
    test "$(${runtime}/bin/omarchy-channel-current)" = stable
    ${runtime}/bin/omarchy-channel-set stable | grep -F 'already on the stable channel'
    OMIXOS_SYSTEM_DRY_RUN=1 ${runtime}/bin/omarchy-update-time |
      grep -F 'systemd-timesyncd.service'
    OMIXOS_SYSTEM_DRY_RUN=1 ${runtime}/bin/omarchy-update-system-pkgs |
      grep -Fx 'omarchy-update -y'
    OMIXOS_SYSTEM_DRY_RUN=1 ${runtime}/bin/omarchy-sudo-reset |
      grep -F 'faillock --reset'
    ${runtime}/bin/omarchy-provision-user |
      grep -F 'Home Manager owns idempotent user provisioning'
    OMIXOS_PREINSTALLS_DRY_RUN=1 ${runtime}/bin/omarchy-install-preinstalls |
      grep -F 'libreoffice-fresh'
    OMIXOS_PREINSTALLS_REMOVE_DRY_RUN=1 ${runtime}/bin/omarchy-remove-preinstalls |
      grep -F 'omarchy-pkg-drop aether'
    grep -E '^aether[[:space:]]+aether[[:space:]]+aether[[:space:]]+store[[:space:]]+/nix/store/' \
      ${runtime}/share/omarchy/lib/omixos-package-map.tsv
    mkdir -p "$TMPDIR/unsupported-home" "$TMPDIR/unsupported-state"
    if HOME="$TMPDIR/unsupported-home" XDG_STATE_HOME="$TMPDIR/unsupported-state" \
      ${runtime}/bin/omarchy-pkg-add steam 2>"$TMPDIR/steam-error"; then
      echo 'Steam unexpectedly installed on ARM64' >&2
      exit 1
    fi
    grep -F 'requires the x86/i686 runtime' "$TMPDIR/steam-error"
    grep -F 'local disabled = io.open(home .. "/.local/state/omarchy/toggles/voxtype-disabled", "r")' \
      ${runtime}/share/omarchy/default/hypr/bindings/voxtype.lua
    OMIXOS_SERVICE_DRY_RUN=1 ${runtime}/bin/omarchy-install-service-sunshine |
      grep -F 'systemctl --user enable --now sunshine.service'
    OMIXOS_SERVICE_DRY_RUN=1 ${runtime}/bin/omarchy-remove-service-tailscale |
      grep -F 'systemctl stop tailscaled.service'
    OMIXOS_GAMING_DRY_RUN=1 ${runtime}/bin/omarchy-install-gaming-geforce-now |
      grep -F 'https://play.geforcenow.com'
    OMIXOS_GAMING_DRY_RUN=1 ${runtime}/bin/omarchy-install-gaming-xbox-controllers |
      grep -F 'kernel-module=xpad'
    OMIXOS_SSHD_DRY_RUN=1 ${runtime}/bin/omarchy-setup-security-sshd --key='ssh-ed25519 test' |
      grep -F 'sshd=enabled'
    test "$(${runtime}/bin/omarchy-version)" = \
      "quattro-nixos (f4f3d4c71a0a5c392b20ce05291531881a1b3bfe)"
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
