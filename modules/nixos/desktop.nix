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

    # omarchy-launch-about reads its pinned fastfetch layout from /etc/fastfetch
    # (OMARCHY_FASTFETCH_DIR); without it About renders unfitted and skips the
    # logo animation.
    environment.etc."fastfetch/config.jsonc".source = "${omarchyPath}/etc/fastfetch/config.jsonc";

    environment.etc."wayland-sessions/omixos.desktop".text = ''
      [Desktop Entry]
      Name=OmixOS (Omarchy quattro)
      Comment=Omarchy quattro on NixOS, managed by UWSM
      Exec=${sessionCommand}
      TryExec=uwsm
      Type=Application
    '';

    fonts = {
      # The default package set adds unifont/freefont and the CJK serif family
      # on top of what quattro actually names. Ship exactly the upstream font
      # surface: JetBrainsMono Nerd Font, Liberation Sans/Serif, Noto with
      # CJK sans and color emoji, plus DejaVu as the broad fallback.
      enableDefaultPackages = false;
      packages = with pkgs; [
        dejavu_fonts
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        # The full nerd-fonts family ships 96 files across three variants
        # (~220 MiB). Quattro references only "JetBrainsMono Nerd Font"; keep
        # that variant's complete weight set and drop the Mono/Propo/NL twins.
        (pkgs.runCommand "nerd-fonts-jetbrains-mono-core" { } ''
          fonts="$out/share/fonts/truetype/NerdFonts/JetBrainsMono"
          mkdir -p "$fonts"
          cp ${nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-*.ttf \
            "$fonts/"
        '')
        omarchy-fonts
      ];
      fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
