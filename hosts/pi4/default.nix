{
  config,
  inputs,
  lib,
  nixos-raspberrypi,
  ...
}:

let
  # The Pi hardware package set replaces FFmpeg globally with ffmpeg-rpi.
  # Chromium then gets a distinct 57k-action source build even though it does
  # not require a board-specific browser build. Use the same pinned generic
  # ARM Chromium as the shared dev host; VC4 and media policy remain owned by
  # the Pi hardware modules and are verified separately on the real device.
  genericPkgs = import inputs.nixpkgs {
    system = "aarch64-linux";
  };
in
{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-4.base
    raspberry-pi-4.display-vc4
    raspberry-pi-4.bluetooth
  ];

  networking.hostName = "omixos-pi4";

  nixpkgs.overlays = [
    (_final: _prev: {
      inherit (genericPkgs) chromium;
    })
  ];

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
