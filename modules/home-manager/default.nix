{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.omarchy;
  runtime = cfg.package;
  omarchyPath = "${runtime}/share/omarchy";
  voxtypeModelName = "ggml-base.en.bin";
in
{
  options.programs.omarchy = {
    enable = lib.mkEnableOption "writable Omarchy quattro user state";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.omarchy-runtime;
      defaultText = lib.literalExpression "pkgs.omarchy-runtime";
      description = "Immutable Omarchy runtime whose defaults seed writable user state.";
    };

    initialTheme = lib.mkOption {
      type = lib.types.str;
      default = "Tokyo Night";
      description = "Theme seeded only when no active theme exists.";
    };

    dictation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Omarchy-compatible VoxType dictation.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.voxtype;
        defaultText = lib.literalExpression "pkgs.voxtype";
        description = "Pinned VoxType package used by the Omarchy dictation workflow.";
      };

      osdPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.voxtype-osd-gtk4;
        defaultText = lib.literalExpression "pkgs.voxtype-osd-gtk4";
        description = "Pinned GTK4 layer-shell OSD used by the VoxType daemon.";
      };

      modelPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.voxtype-model-base-en;
        defaultText = lib.literalExpression "pkgs.voxtype-model-base-en";
        description = "Default Whisper base.en model included for offline first use.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      runtime
    ]
    ++ lib.optionals cfg.dictation.enable [
      cfg.dictation.package
      cfg.dictation.osdPackage
    ];
    home.sessionPath = [
      "/etc/profiles/per-user/$USER/bin"
      "$HOME/.nix-profile/bin"
    ];
    home.sessionVariables = {
      OMARCHY_PATH = omarchyPath;
      EDITOR = "omarchy-launch-editor --inline";
    };
    xdg.enable = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/mailto" = [ "chromium-browser.desktop" ];
      };
    };

    programs.bash = {
      enable = true;
      initExtra = ''
        export OMARCHY_PATH=${lib.escapeShellArg omarchyPath}
        source ${omarchyPath}/default/bash/rc
      '';
    };

    systemd.user.services = {
      omarchy-crash-watch = {
        Unit = {
          Description = "Announce process crashes and offer an AI diagnosis";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
          ConditionPathExists = "!%h/.local/state/omarchy/toggles/crash-capture-off";
        };
        Service = {
          ExecStart = "${runtime}/bin/omarchy-crash-watch";
          Restart = "always";
          RestartSec = 5;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      omarchy-recover-internal-monitor = {
        Unit = {
          Description = "Recover the internal monitor toggle when no external display is connected";
          Before = [ "graphical-session-pre.target" ];
          ConditionPathExists = "%h/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${runtime}/bin/omarchy-hw-recover-internal-monitor";
        };
        Install.WantedBy = [ "graphical-session-pre.target" ];
      };

      omarchy-sleep-lock = {
        Unit = {
          Description = "Lock OmixOS before suspend";
          After = [
            "dbus.socket"
            "wayland-session-waitenv.service"
          ];
          Requires = [ "dbus.socket" ];
          PartOf = [ "graphical-session.target" ];
          ConditionEnvironment = [
            "OMARCHY_PATH"
            "WAYLAND_DISPLAY"
          ];
        };
        Service = {
          ExecStart = "${runtime}/bin/omarchy-system-sleep-monitor";
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      voxtype = lib.mkIf cfg.dictation.enable {
        Unit = {
          Description = "VoxType push-to-talk voice-to-text daemon";
          Documentation = "https://voxtype.io";
          After = [
            "graphical-session.target"
            "pipewire.service"
            "pipewire-pulse.service"
          ];
          PartOf = [ "graphical-session.target" ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
          ConditionPathExists = "!%h/.local/state/omarchy/toggles/voxtype-disabled";
        };
        Service = {
          Type = "simple";
          ExecStart = "${cfg.dictation.package}/bin/voxtype daemon";
          Environment = "PATH=${
            lib.makeBinPath [
              cfg.dictation.package
              cfg.dictation.osdPackage
              pkgs.libnotify
              pkgs.wl-clipboard
              pkgs.wtype
            ]
          }";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };

    home.activation.omarchySeedWritableState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      seed_path() {
        source_path="$1"
        target_path="$2"

        if [[ ! -e "$target_path" ]]; then
          mkdir -p "$(dirname "$target_path")"
          cp -R --no-preserve=ownership,mode "$source_path" "$target_path"
          chmod -R u+w "$target_path"
        fi
      }

      mkdir -p \
        "$HOME/.config/omarchy/plugins" \
        "$HOME/.config/omarchy/themes" \
        "$HOME/.config/omarchy/backgrounds" \
        "$HOME/.config/uwsm/env.d" \
        "$HOME/.local/state/omarchy/current" \
        "$HOME/.local/state/omarchy/migrations" \
        "$HOME/.local/state/omarchy/toggles/hypr" \
        "$HOME/.local/share/voxtype/models" \
        "$HOME/.local/share/applications"

      seed_path ${omarchyPath}/default/uwsm/default "$HOME/.config/uwsm/default"
      seed_path ${omarchyPath}/default/uwsm/env.d/10-omarchy "$HOME/.config/uwsm/env.d/10-omarchy"
      ${lib.optionalString cfg.dictation.enable ''
        seed_path ${omarchyPath}/default/voxtype/config.toml "$HOME/.config/voxtype/config.toml"
        if [[ ! -e "$HOME/.local/share/voxtype/models/${voxtypeModelName}" ]]; then
          ln -s ${cfg.dictation.modelPackage} "$HOME/.local/share/voxtype/models/${voxtypeModelName}"
        fi
      ''}
      terminal_preference="$HOME/.config/xdg-terminals.list"
      terminal_migration="$HOME/.local/state/omarchy/migrations/default-terminal-ghostty-v1"
      if [[ ! -e "$terminal_migration" ]]; then
        if [[ ! -e "$terminal_preference" ]] || [[ "$(cat "$terminal_preference")" == foot.desktop ]]; then
          printf '%s\n' com.mitchellh.ghostty.desktop > "$terminal_preference"
        fi
        touch "$terminal_migration"
      fi

      while IFS= read -r -d "" source_path; do
        seed_path "$source_path" "$HOME/.config/$(basename "$source_path")"
      done < <(find ${omarchyPath}/config -mindepth 1 -maxdepth 1 -print0)

      while IFS= read -r -d "" source_path; do
        seed_path "$source_path" "$HOME/.local/share/applications/$(basename "$source_path")"
      done < <(find ${omarchyPath}/applications -maxdepth 1 -type f -name "*.desktop" -print0)

      application_migration="$HOME/.local/state/omarchy/migrations/application-profile-v1"
      if [[ ! -e "$application_migration" ]]; then
        basecamp_launcher="$HOME/.local/share/applications/Basecamp.desktop"
        hey_launcher="$HOME/.local/share/applications/HEY.desktop"
        if [[ -f "$basecamp_launcher" ]] && grep -Fq \
          'Exec=omarchy-launch-webapp https://launchpad.37signals.com' "$basecamp_launcher"; then
          rm -f "$basecamp_launcher"
        fi
        if [[ -f "$hey_launcher" ]] && grep -Fq \
          'Exec=omarchy-webapp-handler-hey %u' "$hey_launcher"; then
          rm -f "$hey_launcher"
        fi
        touch "$application_migration"
      fi

      while IFS= read -r -d "" source_path; do
        seed_path "$source_path" "$HOME/.local/state/omarchy/toggles/hypr/$(basename "$source_path")"
      done < <(find ${omarchyPath}/default/hypr/toggles -maxdepth 1 -type f -name "*.lua" -print0)

      # Upstream migration 1787481315: re-stage the current theme once so any
      # code files an installed repo theme smuggled into the staged copy are
      # dropped by the hardened staging path. Fresh homes have no theme yet and
      # only record the marker; the initial seed below already stages safely.
      theme_restage_migration="$HOME/.local/state/omarchy/migrations/theme-restage-v1"
      if [[ ! -e "$theme_restage_migration" ]]; then
        if [[ -s "$HOME/.local/state/omarchy/current/theme.name" ]]; then
          HOME="$HOME" OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
            ${runtime}/bin/omarchy-theme-set \
            "$(cat "$HOME/.local/state/omarchy/current/theme.name")" || true
        fi
        touch "$theme_restage_migration"
      fi

      if [[ ! -s "$HOME/.local/state/omarchy/current/theme.name" ]]; then
        HOME="$HOME" OMARCHY_THEME_HEADLESS=1 \
          ${runtime}/bin/omarchy-theme-set ${lib.escapeShellArg cfg.initialTheme}
      fi
    '';
  };
}
