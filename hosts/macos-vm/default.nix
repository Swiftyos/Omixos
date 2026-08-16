{ lib, modulesPath, ... }:

{
  # Nixpkgs's LKL cptofs helper hard-codes a 100 MiB kernel allocation. That is
  # too small to populate this desktop closure and deadlocks in the page cache.
  # The override affects only image construction; it does not change guest RAM.
  nixpkgs.overlays = [
    (_final: prev: {
      lkl = prev.lkl.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace tools/lkl/cptofs.c \
            --replace-fail 'lkl_start_kernel("mem=100M")' \
            'lkl_start_kernel("mem=512M")'
        '';
      });
    })
  ];

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/nixos/first-boot-password.nix
  ];

  networking.hostName = "omixos-macos-vm";

  boot = {
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.efi.canTouchEfiVariables = false;
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
  };

  fileSystems = {
    "/" = {
      device = lib.mkDefault "/dev/disk/by-label/nixos";
      fsType = lib.mkDefault "ext4";
    };

    "/boot" = {
      # Manual installs in docs/macos.md use EFI. NixOS's qemu-efi image
      # builder supplies its own stronger ESP label for the packaged image.
      device = lib.mkDefault "/dev/disk/by-label/EFI";
      fsType = lib.mkDefault "vfat";
      options = [ "umask=0077" ];
    };
  };

  swapDevices = [ ];

  virtualisation.vmVariant.virtualisation = {
    cores = 8;
    memorySize = 16384;
  };
  # The complete Asahi installer kernel uses more than 32 GiB of temporary
  # space when it is built natively. Keep enough sparse capacity for the VM to
  # serve as the documented Apple-silicon USB build environment.
  virtualisation.diskSize = 128 * 1024;

  users.users.root.initialHashedPassword = lib.mkForce "!";

  omixos = {
    firstBootPassword.enable = true;
    omarchy = {
      profile = "workstation";
      features = {
        containers = true;
        gaming = false;
        heavyApplications = true;
        printing = false;
        recording = false;
      };
    };
  };
}
