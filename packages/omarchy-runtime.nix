{
  lib,
  stdenvNoCC,
  makeWrapper,
  bash,
  coreutils,
  curl,
  dbus,
  file,
  findutils,
  fzf,
  gawk,
  git,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  gum,
  inetutils,
  jq,
  less,
  libnotify,
  perl,
  procps,
  python3,
  socat,
  systemd,
  unzip,
  util-linux,
  which,
  xdg-utils,
  nix,
  nixpkgsRef,
  omarchySrc,
  aetherPackage,
}:

let
  upstreamRevision = "30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec";
  runtimeDependencies = [
    bash
    coreutils
    curl
    dbus
    file
    findutils
    fzf
    gawk
    git
    gnugrep
    gnused
    gnutar
    gzip
    gum
    inetutils
    jq
    less
    libnotify
    perl
    procps
    python3
    socat
    systemd
    unzip
    util-linux
    which
    xdg-utils
    nix
  ];
in
stdenvNoCC.mkDerivation {
  pname = "omarchy-runtime";
  version = "quattro-${builtins.substring 0 12 upstreamRevision}";

  src = omarchySrc;
  nativeBuildInputs = [
    makeWrapper
    python3
  ];
  dontBuild = true;

  installPhase = ''
        runHook preInstall

        runtime="$out/share/omarchy"
        mkdir -p "$runtime" "$out/bin"

        for tree in bin config default themes applications shell; do
          cp -R "$src/$tree" "$runtime/$tree"
        done

        # Curate the installed web-app profile independently of the upstream
        # repository. OmixOS intentionally omits 37signals launchers and provides
        # ARM-safe browser applications for Linear and Slack.
        chmod -R u+w "$runtime/applications"
        rm -f \
          "$runtime/applications/Basecamp.desktop" \
          "$runtime/applications/HEY.desktop" \
          "$runtime/applications/icons/Basecamp.png" \
          "$runtime/applications/icons/HEY.png"
        install -m 0644 ${./applications/Linear.desktop} "$runtime/applications/Linear.desktop"
        install -m 0644 ${./applications/Slack.desktop} "$runtime/applications/Slack.desktop"

        for asset in LICENSE logo.txt logo.svg icon.txt icon.png; do
          if [[ -e "$src/$asset" ]]; then
            cp -R "$src/$asset" "$runtime/$asset"
          fi
        done

        printf '%s\n' '${upstreamRevision}' > "$runtime/UPSTREAM_REVISION"
        chmod -R u+w "$runtime"

        # The menu's package guard snapshot is intentionally optimized around
        # Pacman upstream. Replace it before any generic source patching so menu
        # install/remove state comes from the Nix-native package inventory.
        patch -p1 -d "$runtime" < ${./patches/menu-nix-package-guards.patch}

        # Remove the remaining functional HEY integration from the curated
        # profile: its handler, preinstalled hotkeys, and mailto association.
        # Upstream attribution and documentation links are intentionally kept.
        rm -f "$runtime/bin/omarchy-webapp-handler-hey"
        sed -i '\|webapp = "https://app\.hey\.com|d' \
          "$runtime/default/hypr/bindings/applications.lua"
        substituteInPlace "$runtime/default/applications/mimeapps.list" \
          --replace-fail \
          'x-scheme-handler/mailto=HEY.desktop' \
          'x-scheme-handler/mailto=chromium-browser.desktop'

        find "$runtime/bin" -type f -exec chmod 0755 {} +
        patchShebangs "$runtime/bin" "$runtime/shell"

        # Theme assets copied from the Nix store inherit read-only directory modes.
        # Make each freshly staged theme writable before it becomes user state so
        # later live switches can replace nested backgrounds and generated files.
        substituteInPlace "$runtime/bin/omarchy-theme-set" \
          --replace-fail \
          'cp -r "$USER_THEMES_PATH/$THEME_NAME/"* "$NEXT_THEME_PATH/" 2>/dev/null' \
          'cp -r "$USER_THEMES_PATH/$THEME_NAME/"* "$NEXT_THEME_PATH/" 2>/dev/null; chmod -R u+w "$NEXT_THEME_PATH"'

        # Quickshell's plugin graph can take substantially longer than two seconds
        # to become IPC-ready on a Pi or under AArch64 TCG. Keep the upstream
        # restart sequence, but allow each readiness probe the normal two-second
        # IPC budget and bound the complete retry loop.
        substituteInPlace "$runtime/bin/omarchy-restart-shell" \
          --replace-fail \
          'for (( attempt = 0; attempt < 20; attempt++ )); do' \
          'for (( attempt = 0; attempt < 40; attempt++ )); do' \
          --replace-fail \
          'OMARCHY_SHELL_IPC_TIMEOUT=0.5s omarchy-shell shell ping' \
          'OMARCHY_SHELL_IPC_TIMEOUT=2s omarchy-shell shell ping'

        # Replace Arch/system-mutating entry points with an explicit NixOS boundary.
        # The source remains packaged for attribution and inventory, but these paths
        # must never invoke Pacman, edit /etc, or change boot configuration on NixOS.
        for command in \
          "$runtime/bin"/omarchy-apply-* \
          "$runtime/bin"/omarchy-channel-* \
          "$runtime/bin"/omarchy-brightness-display-apple \
          "$runtime/bin"/omarchy-dev-add-migration \
          "$runtime/bin"/omarchy-dev-install-ydoo \
          "$runtime/bin"/omarchy-dev-link \
          "$runtime/bin"/omarchy-dev-pkg-test \
          "$runtime/bin"/omarchy-dev-status \
          "$runtime/bin"/omarchy-dev-unlink \
          "$runtime/bin"/omarchy-dns \
          "$runtime/bin"/omarchy-drive-password \
          "$runtime/bin"/omarchy-hibernation-remove \
          "$runtime/bin"/omarchy-hibernation-setup \
          "$runtime/bin"/omarchy-install-* \
          "$runtime/bin"/omarchy-menu-timezone \
          "$runtime/bin"/omarchy-pkg-* \
          "$runtime/bin"/omarchy-plymouth-* \
          "$runtime/bin"/omarchy-provision-* \
          "$runtime/bin"/omarchy-refresh-limine \
          "$runtime/bin"/omarchy-refresh-pacman \
          "$runtime/bin"/omarchy-refresh-plymouth \
          "$runtime/bin"/omarchy-refresh-sddm \
          "$runtime/bin"/omarchy-reinstall \
          "$runtime/bin"/omarchy-reinstall-* \
          "$runtime/bin"/omarchy-remove-browser \
          "$runtime/bin"/omarchy-remove-dev-env \
          "$runtime/bin"/omarchy-remove-gaming-* \
          "$runtime/bin"/omarchy-remove-launcher-entry \
          "$runtime/bin"/omarchy-remove-security-* \
          "$runtime/bin"/omarchy-remove-service-* \
          "$runtime/bin"/omarchy-setup-direct-boot \
          "$runtime/bin"/omarchy-setup-security-* \
          "$runtime/bin"/omarchy-snapshot \
          "$runtime/bin"/omarchy-sudo-* \
          "$runtime/bin"/omarchy-system-factory-reset \
          "$runtime/bin"/omarchy-system-factory-reset-finish \
          "$runtime/bin"/omarchy-restart-trackpad \
          "$runtime/bin"/omarchy-toggle-hybrid-gpu \
          "$runtime/bin"/omarchy-update* \
          "$runtime/bin"/omarchy-upgrade-to-quattro \
          "$runtime/bin"/omarchy-windows-vm; do
          [[ -e "$command" ]] || continue
          install -m 0755 ${./overrides/omarchy-nixos-unsupported} "$command"
        done

        install -m 0755 ${./overrides/omarchy-update} "$runtime/bin/omarchy-update"
        install -m 0755 ${./overrides/omarchy-update-available} "$runtime/bin/omarchy-update-available"
        for nixos_system_command in \
          omarchy-apply-hardware \
          omarchy-apply-lock \
          omarchy-apply-system \
          omarchy-channel-current \
          omarchy-channel-set \
          omarchy-refresh-limine \
          omarchy-refresh-pacman \
          omarchy-refresh-sddm \
          omarchy-reinstall \
          omarchy-reinstall-configs \
          omarchy-reinstall-pkgs \
          omarchy-provision-owner \
          omarchy-provision-user \
          omarchy-setup-direct-boot \
          omarchy-snapshot \
          omarchy-sudo-reset \
          omarchy-update-aur-pkgs \
          omarchy-update-firmware \
          omarchy-update-keyring \
          omarchy-update-orphan-pkgs \
          omarchy-update-pacman-guard \
          omarchy-update-pkg-prune \
          omarchy-update-restart \
          omarchy-update-system-pkgs \
          omarchy-update-system-pkgs-when-conflicted \
          omarchy-update-time \
          omarchy-upgrade-to-quattro; do
          install -m 0755 ${./overrides/omarchy-nixos-system-command} "$runtime/bin/$nixos_system_command"
        done
        for portable_update in \
          omarchy-update-analyze-logs \
          omarchy-update-confirm \
          omarchy-update-dev \
          omarchy-update-lock \
          omarchy-update-mise \
          omarchy-update-requires-free-space \
          omarchy-update-status \
          omarchy-update-stay-awake \
          omarchy-update-user-notify; do
          install -m 0755 "$src/bin/$portable_update" "$runtime/bin/$portable_update"
        done
        install -m 0755 ${./overrides/omarchy-pkg-present} "$runtime/bin/omarchy-pkg-present"
        install -m 0755 ${./overrides/omarchy-pkg-missing} "$runtime/bin/omarchy-pkg-missing"
        install -m 0755 ${./overrides/omarchy-pkg-add} "$runtime/bin/omarchy-pkg-add"
        install -m 0755 ${./overrides/omarchy-pkg-aur-accessible} "$runtime/bin/omarchy-pkg-aur-accessible"
        install -m 0755 ${./overrides/omarchy-pkg-aur-add} "$runtime/bin/omarchy-pkg-aur-add"
        install -m 0755 ${./overrides/omarchy-pkg-aur-install} "$runtime/bin/omarchy-pkg-aur-install"
        install -m 0755 ${./overrides/omarchy-pkg-drop} "$runtime/bin/omarchy-pkg-drop"
        install -m 0755 ${./overrides/omarchy-pkg-install} "$runtime/bin/omarchy-pkg-install"
        install -m 0755 ${./overrides/omarchy-pkg-list} "$runtime/bin/omarchy-pkg-list"
        install -m 0755 ${./overrides/omarchy-pkg-remove} "$runtime/bin/omarchy-pkg-remove"
        install -m 0755 ${./overrides/omarchy-provision-first-run} "$runtime/bin/omarchy-provision-first-run"
        install -m 0755 ${./overrides/omarchy-migrate} "$runtime/bin/omarchy-migrate"
        install -m 0755 ${./overrides/omarchy-dns} "$runtime/bin/omarchy-dns"
        install -m 0755 ${./overrides/omarchy-menu-timezone} "$runtime/bin/omarchy-menu-timezone"
        install -m 0755 ${./overrides/omarchy-install-preinstalls} "$runtime/bin/omarchy-install-preinstalls"
        install -m 0755 ${./overrides/omarchy-remove-preinstalls} "$runtime/bin/omarchy-remove-preinstalls"
        install -m 0755 ${./overrides/omarchy-install-browser} "$runtime/bin/omarchy-install-browser"
        install -m 0755 ${./overrides/omarchy-install-dev-env} "$runtime/bin/omarchy-install-dev-env"
        install -m 0755 ${./overrides/omarchy-remove-dev-env} "$runtime/bin/omarchy-remove-dev-env"
        install -m 0755 "$src/bin/omarchy-install-chromium-google-account" "$runtime/bin/omarchy-install-chromium-google-account"
        install -m 0755 "$src/bin/omarchy-dev-add-migration" "$runtime/bin/omarchy-dev-add-migration"
        for gaming_command in \
          omarchy-install-gaming-geforce-now \
          omarchy-remove-gaming-geforce-now \
          omarchy-install-gaming-xbox-controllers \
          omarchy-remove-gaming-xbox-controllers \
          omarchy-install-gaming-gpu-lib32; do
          install -m 0755 ${./overrides/omarchy-nixos-gaming-command} "$runtime/bin/$gaming_command"
        done
        for service_command in \
          omarchy-install-service-sunshine \
          omarchy-remove-service-sunshine \
          omarchy-install-service-tailscale \
          omarchy-remove-service-tailscale \
          omarchy-remove-service-1password; do
          install -m 0755 ${./overrides/omarchy-nixos-service-command} "$runtime/bin/$service_command"
        done
        for sshd_command in omarchy-setup-security-sshd omarchy-remove-security-sshd; do
          install -m 0755 ${./overrides/omarchy-nixos-sshd-command} "$runtime/bin/$sshd_command"
        done
        install -m 0755 "$src/bin/omarchy-sudo-keepalive" "$runtime/bin/omarchy-sudo-keepalive"
        install -m 0755 "$src/bin/omarchy-sudo-passwordless" "$runtime/bin/omarchy-sudo-passwordless"
        for catalog_installer in \
          omarchy-install-ai-chatgpt \
          omarchy-install-editor-emacs \
          omarchy-install-editor-zed \
          omarchy-install-service-1password \
          omarchy-install-service-dropbox \
          omarchy-install-service-signal \
          omarchy-install-service-spotify \
          omarchy-install-gaming-heroic \
          omarchy-install-gaming-lutris \
          omarchy-install-gaming-retroarch \
          omarchy-install-gaming-steam; do
          install -m 0755 ${./overrides/omarchy-install-catalog-app} "$runtime/bin/$catalog_installer"
        done
        install -m 0755 ${./overrides/omarchy-remove-browser} "$runtime/bin/omarchy-remove-browser"
        install -m 0755 ${./overrides/omarchy-remove-launcher-entry} "$runtime/bin/omarchy-remove-launcher-entry"
        install -m 0755 ${./overrides/omarchy-debug} "$runtime/bin/omarchy-debug"
        install -m 0755 ${./overrides/omarchy-default-browser} "$runtime/bin/omarchy-default-browser"
        install -m 0755 ${./overrides/omarchy-launch-browser} "$runtime/bin/omarchy-launch-browser"
        install -m 0755 ${./overrides/omarchy-launch-webapp} "$runtime/bin/omarchy-launch-webapp"
        install -m 0755 ${./overrides/omarchy-theme-set-browser} "$runtime/bin/omarchy-theme-set-browser"
        install -m 0755 ${./overrides/omarchy-version} "$runtime/bin/omarchy-version"
        install -m 0755 ${./overrides/omarchy-version-channel} "$runtime/bin/omarchy-version-channel"
        install -m 0755 ${./overrides/omarchy-version-pkgs} "$runtime/bin/omarchy-version-pkgs"
        install -m 0755 ${./overrides/omarchy-voxtype-install} "$runtime/bin/omarchy-voxtype-install"
        install -m 0755 ${./overrides/omarchy-voxtype-remove} "$runtime/bin/omarchy-voxtype-remove"
        install -m 0755 ${./overrides/omarchy-voxtype-status} "$runtime/bin/omarchy-voxtype-status"

        mkdir -p "$runtime/lib"
        install -m 0644 ${./overrides/omixos-package-map.tsv} "$runtime/lib/omixos-package-map.tsv"
        substituteInPlace "$runtime/lib/omixos-package-map.tsv" \
          --replace-fail '@aetherStore@' '${aetherPackage}'
        substituteInPlace "$runtime/bin/omarchy-pkg-add" \
          --replace-fail '@nixpkgsRef@' '${nixpkgsRef}'
        substituteInPlace "$runtime/bin/omarchy-pkg-install" \
          --replace-fail '@nixpkgsRef@' '${nixpkgsRef}'

        # UWSM does not source a login shell. Import user-profile binaries and
        # desktop entries explicitly so a newly installed app appears in the
        # Quickshell app library and can be launched during the same session.
        cat >>"$runtime/default/uwsm/env.d/10-omarchy" <<'EOF'

    # OmixOS user packages installed through omarchy-pkg-add.
    case ":$PATH:" in
      *":/etc/profiles/per-user/$USER/bin:"*) ;;
      *) export PATH="/etc/profiles/per-user/$USER/bin:$PATH" ;;
    esac
    case ":$PATH:" in
      *":$HOME/.nix-profile/bin:"*) ;;
      *) export PATH="$HOME/.nix-profile/bin:$PATH" ;;
    esac
    case ":''${XDG_DATA_DIRS:-}:" in
      *":/etc/profiles/per-user/$USER/share:"*) ;;
      *) export XDG_DATA_DIRS="/etc/profiles/per-user/$USER/share:''${XDG_DATA_DIRS:-/run/current-system/sw/share}" ;;
    esac
    case ":''${XDG_DATA_DIRS:-}:" in
      *":$HOME/.nix-profile/share:"*) ;;
      *) export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/run/current-system/sw/share}" ;;
    esac
    EOF

        # These upstream installers only mutate writable user state and delegate
        # package work to omarchy-pkg-add, whose implementation above is Nix-native.
        # Restore them after the broad Arch installer boundary replaced the rest.
        for portable_installer in \
          omarchy-install-and-launch \
          omarchy-install-app \
          omarchy-install-chromium-copy-url \
          omarchy-install-chromium-ytdlp \
          omarchy-install-docker-dbs \
          omarchy-install-editor-helix \
          omarchy-install-editor-vscode \
          omarchy-install-font \
          omarchy-install-gaming-xbox-cloud \
          omarchy-install-terminal; do
          install -m 0755 "$src/bin/$portable_installer" "$runtime/bin/$portable_installer"
        done

        for portable_remover in \
          omarchy-remove-gaming-geforce-now \
          omarchy-remove-gaming-heroic \
          omarchy-remove-gaming-lutris \
          omarchy-remove-gaming-retroarch \
          omarchy-remove-gaming-steam \
          omarchy-remove-gaming-xbox-cloud \
          omarchy-remove-service-dropbox; do
          install -m 0755 "$src/bin/$portable_remover" "$runtime/bin/$portable_remover"
        done

        # VoxType stays in the declarative closure, while its install/remove menu
        # actions enable or disable the user service. Hide its bindings whenever
        # the user has selected Remove > Dictation.
        install -m 0644 ${./overrides/hypr-voxtype.lua} \
          "$runtime/default/hypr/bindings/voxtype.lua"


        mkdir -p "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"
        cp "$runtime"/applications/*.desktop "$out/share/applications/"
        for icon in "$runtime"/applications/icons/*.png; do
          icon_name="$(basename "''${icon%.png}" | tr '[:upper:] ' '[:lower:]-')"
          install -m 0644 "$icon" "$out/share/icons/hicolor/256x256/apps/$icon_name.png"
        done

        patchShebangs "$runtime/bin"

        for program in "$runtime/bin"/omarchy*; do
          [[ -x "$program" ]] || continue
          name="$(basename "$program")"
          makeWrapper "$program" "$out/bin/$name" \
            --set OMARCHY_PATH "$runtime" \
            --prefix PATH : "$runtime/bin:${lib.makeBinPath runtimeDependencies}"
        done

        runHook postInstall
  '';

  passthru = {
    inherit runtimeDependencies upstreamRevision;
    omarchyPath = "${placeholder "out"}/share/omarchy";
  };

  meta = {
    description = "Immutable Omarchy quattro runtime adapted for NixOS";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
