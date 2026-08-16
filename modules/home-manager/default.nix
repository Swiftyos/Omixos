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
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ runtime ];
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
        "$HOME/.local/state/omarchy/toggles/hypr" \
        "$HOME/.local/share/applications"

      seed_path ${omarchyPath}/default/uwsm/default "$HOME/.config/uwsm/default"
      seed_path ${omarchyPath}/default/uwsm/env.d/10-omarchy "$HOME/.config/uwsm/env.d/10-omarchy"
      if [[ ! -e "$HOME/.config/xdg-terminals.list" ]]; then
        printf '%s\n' foot.desktop > "$HOME/.config/xdg-terminals.list"
      fi

      while IFS= read -r -d "" source_path; do
        seed_path "$source_path" "$HOME/.config/$(basename "$source_path")"
      done < <(find ${omarchyPath}/config -mindepth 1 -maxdepth 1 -print0)

      while IFS= read -r -d "" source_path; do
        seed_path "$source_path" "$HOME/.local/share/applications/$(basename "$source_path")"
      done < <(find ${omarchyPath}/applications -maxdepth 1 -type f -name "*.desktop" -print0)

      while IFS= read -r -d "" source_path; do
        seed_path "$source_path" "$HOME/.local/state/omarchy/toggles/hypr/$(basename "$source_path")"
      done < <(find ${omarchyPath}/default/hypr/toggles -maxdepth 1 -type f -name "*.lua" -print0)

      if [[ ! -s "$HOME/.local/state/omarchy/current/theme.name" ]]; then
        HOME="$HOME" OMARCHY_THEME_HEADLESS=1 \
          ${runtime}/bin/omarchy-theme-set ${lib.escapeShellArg cfg.initialTheme}
      fi
    '';
  };
}
