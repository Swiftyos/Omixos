{
  config,
  lib,
  nixos-raspberrypi,
  ...
}:

{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-4.base
    raspberry-pi-4.display-vc4
    raspberry-pi-4.bluetooth
  ];

  networking.hostName = "omixos-pi4";

  fileSystems."/" = {
    device = lib.mkDefault "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Pi 4 keeps the hardware flake's U-Boot default. It owns the firmware,
  # kernel, device tree, VC4/KMS, and Bluetooth configuration.
  system.nixos.tags = [
    "omixos"
    "raspberry-pi-4"
    config.boot.loader.raspberry-pi.bootloader
    config.boot.kernelPackages.kernel.version
  ];

  omixos.omarchy = {
    profile = "core";
    features = {
      containers = false;
      recording = false;
      gaming = false;
      heavyApplications = false;
      printing = false;
    };
  };
}
