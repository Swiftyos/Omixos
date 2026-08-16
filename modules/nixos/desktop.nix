{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.omixos.omarchy;
  omarchyPath = "${cfg.package}/share/omarchy";
  sessionCommand = "${pkgs.uwsm}/bin/uwsm start -g -1 -e -D Hyprland hyprland.desktop";
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [
        "hyprland"
        "gtk"
      ];
    };

    services.greetd = lib.mkIf cfg.greetd.enable {
      enable = true;
      settings.default_session = {
        command =
          if cfg.greetd.autoLogin then
            sessionCommand
          else
            "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${sessionCommand}'";
        user = if cfg.greetd.autoLogin then cfg.user else "greeter";
      };
    };

    environment.sessionVariables = {
      OMARCHY_PATH = omarchyPath;
      TERMINAL = "xdg-terminal-exec";
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "gtk3";
      MOZ_ENABLE_WAYLAND = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    environment.etc."wayland-sessions/omixos.desktop".text = ''
      [Desktop Entry]
      Name=OmixOS (Omarchy quattro)
      Comment=Omarchy quattro on NixOS, managed by UWSM
      Exec=${sessionCommand}
      TryExec=uwsm
      Type=Application
    '';

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
        omarchy-fonts
      ];
      fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
