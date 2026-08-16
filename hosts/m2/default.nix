{
  nixos-apple-silicon,
  ...
}:

{
  imports = [
    nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  networking.hostName = "omixos-m2";

  hardware.asahi = {
    enable = true;

    # A pure flake evaluation cannot read /boot/vendorfw. A real M2 deployment
    # must override these two options with a copied firmware.cpio directory.
    extractPeripheralFirmware = false;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.networkmanager.wifi.backend = "iwd";

  omixos.omarchy = {
    profile = "workstation";
    features = {
      containers = true;
      recording = false;
      gaming = false;
      heavyApplications = true;
      printing = false;
    };
  };
}
