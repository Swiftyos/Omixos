{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.omixos.omarchy;
  available = package: lib.meta.availableOn pkgs.stdenv.hostPlatform package;
  optionalAvailable = package: lib.optional (available package) package;

  corePackages =
    with pkgs;
    [
      bash
      bluez
      brightnessctl
      chromium
      coreutils
      curl
      dbus
      file
      findutils
      foot
      gum
      gawk
      git
      glib
      grim
      hyprpicker
      hyprsunset
      imagemagick
      imv
      inetutils
      jq
      libnotify
      nautilus
      networkmanager
      pamixer
      perl
      procps
      qrencode
      quickshell
      ripgrep
      slurp
      socat
      systemd
      udiskie
      util-linux
      wireplumber
      wl-clipboard
      wtype
      xdg-utils
    ]
    ++ optionalAvailable pkgs.xdg-terminal-exec
    ++ optionalAvailable pkgs.pavucontrol
    ++ optionalAvailable pkgs.playerctl;

  workstationPackages = with pkgs; [
    bat
    btop
    eza
    fd
    fzf
    lazygit
    mpv
    neovim
    tmux
    tree
    unzip
    yt-dlp
    zoxide
  ];

  featurePackages =
    lib.optionals cfg.features.containers (
      with pkgs;
      [
        docker
        docker-compose
        lazydocker
      ]
    )
    ++ lib.optionals cfg.features.recording (optionalAvailable pkgs.obs-studio)
    ++ lib.optionals cfg.features.heavyApplications (
      optionalAvailable pkgs.libreoffice ++ optionalAvailable pkgs.xournalpp
    );
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      cfg.shellPackage
    ]
    ++ corePackages
    ++ lib.optionals (cfg.profile == "workstation") workstationPackages
    ++ featurePackages;

    virtualisation.docker.enable = cfg.features.containers;

    assertions = [
      {
        assertion = lib.all available corePackages;
        message = "An essential OmixOS core package is unavailable on ${pkgs.stdenv.hostPlatform.system}.";
      }
    ];
  };
}
