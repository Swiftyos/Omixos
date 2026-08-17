{
  config,
  inputs,
  lib,
  nixos-raspberrypi,
  omixosGenericPkgs,
  ...
}:

let
  # The Pi hardware package set replaces FFmpeg globally with ffmpeg-rpi.
  # Chromium then gets a distinct 57k-action source build even though it does
  # not require a board-specific browser build. Its transitive package changes
  # also make Ghostty's generated Unicode-table build fail on native ARM.
  # Reuse the same pinned generic ARM application derivations that pass in the
  # shared graphical VM; VC4 and media policy remain owned by the Pi hardware
  # modules and are verified separately on the real device.
  genericNixpkgs = import inputs.nixpkgs {
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
      inherit (genericNixpkgs) chromium ghostty;
      inherit (omixosGenericPkgs)
        aether
        omacalc
        omacut
        omawrite
        omarchy-fonts
        omarchy-runtime
        omarchy-shell
        quickshell
        ;
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
      # Docker and the Omarchy database installer are part of the normal
      # Quattro development workflow and are supported on AArch64.
      containers = true;
      recording = false;
      gaming = false;
      heavyApplications = false;
      printing = false;
    };
  };
}
