{
  config,
  lib,
  ...
}:

let
  cfg = config.omixos.omarchy;
in
{
  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    security = {
      polkit.enable = true;
      rtkit.enable = true;
      pam.services = {
        greetd.enableGnomeKeyring = true;
        omarchy-lock-password = { };
        omarchy-lock-fingerprint = { };
      };
    };

    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      dbus.enable = true;
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      openssh.enable = lib.mkDefault true;
      power-profiles-daemon.enable = true;
      printing.enable = cfg.features.printing;
      udisks2.enable = true;
      upower.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = false;
        pulse.enable = true;
        wireplumber.enable = true;
      };
    };

    networking.firewall.enable = true;
  };
}
