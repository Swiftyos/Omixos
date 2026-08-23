{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Keep the image lean: a copy of the Nixpkgs source tree in the registry and
  # NIX_PATH costs ~200 MiB and nothing OmixOS ships evaluates through it.
  # omarchy-pkg-add pins Nixpkgs by explicit github reference instead.
  nixpkgs.flake = {
    setNixPath = false;
    setFlakeRegistry = false;
  };

  # Man pages stay; the NixOS manual, info pages, and linked -doc outputs are
  # dead weight on an appliance image.
  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  networking.useDHCP = lib.mkDefault true;
  # None of the declared targets use ZFS for root. Avoid opportunistic pool
  # imports and opt into the safer default that NixOS will use from 26.11.
  boot.zfs.forceImportRoot = false;
  time.timeZone = lib.mkDefault "Europe/Madrid";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  users.mutableUsers = true;
  users.users.omix = {
    isNormalUser = true;
    description = "OmixOS user";
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "video"
      "wheel"
    ];
    initialHashedPassword = "!";
  };

  security.sudo.wheelNeedsPassword = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    sharedModules = [ ../modules/home-manager ];
    users.omix = {
      programs.omarchy.enable = true;
      home = {
        username = "omix";
        homeDirectory = "/home/omix";
        stateVersion = "26.05";
      };
    };
  };

  omixos.omarchy = {
    enable = true;
    user = "omix";
    profile = lib.mkDefault "core";
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "26.05";
}
