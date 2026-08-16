{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.hostName = "omixos-dev";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  virtualisation.vmVariant = {
    virtualisation = {
      cores = 6;
      memorySize = 8192;
    };
  };

  omixos.omarchy.profile = "workstation";
}
