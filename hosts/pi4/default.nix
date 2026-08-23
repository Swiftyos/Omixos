{
  config,
  inputs,
  lib,
  pkgs,
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

  # The hardware flake turns on the full redistributable linux-firmware set
  # (~780 MiB) for a board whose radios only need the Broadcom 43455 blobs.
  # Anything the VC4/KMS stack needs lives in raspberrypi-firmware, which the
  # base module manages separately.
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  # Stock Mesa bundles llvmpipe/lavapipe software rendering, which alone costs
  # ~790 MiB of LLVM and would be unusably slow on this board anyway. The Pi 4
  # renders through VC4/V3D GL and the Broadcom Vulkan driver; the console
  # keeps working without Mesa if V3D ever fails to probe.
  hardware.graphics.package =
    (pkgs.mesa.override {
      galliumDrivers = [
        "v3d"
        "vc4"
      ];
      vulkanDrivers = [ "broadcom" ];
    }).overrideAttrs
      (old: {
        # Meson's llvm feature is auto-detected from the build PATH and links
        # LLVM into libgallium's draw fallback even when llvmpipe is not
        # built; rusticl and the VA tracker are its other consumers. The V3D
        # and VC4 hardware paths use none of them.
        mesonFlags = old.mesonFlags ++ [
          (lib.mesonEnable "llvm" false)
          (lib.mesonBool "gallium-rusticl" false)
          (lib.mesonEnable "gallium-va" false)
          # Nixpkgs builds the asahi/panfrost cross tools and the mesa-clc /
          # precomp compilers on native builds; those are the remaining CLC
          # (and therefore LLVM) consumers. None of them serve V3D/VC4.
          (lib.mesonOption "tools" "")
          (lib.mesonBool "install-mesa-clc" false)
          (lib.mesonBool "install-precomp-compiler" false)
        ];
        # Nixpkgs declares the spirv2dxil, opencl, and cross_tools outputs
        # unconditionally, but only the dropped drivers populate them; the
        # fixed-up rusticl ICD and rpath refer to a library that no longer
        # exists.
        postInstall = (old.postInstall or "") + ''
          mkdir -p "$spirv2dxil" "$opencl" "$cross_tools"
          rm -f "$opencl"/etc/OpenCL/vendors/rusticl.icd
        '';
        postFixup = builtins.replaceStrings [ " $opencl/lib/libRusticlOpenCL.so" ] [ "" ] (
          old.postFixup or ""
        );
      });

  # mkAfter keeps this substitution overlay behind the OmixOS and hardware
  # overlays in every module-set variant. The image builder composes overlays
  # in a different order than nixosSystem, and losing this ordering once made
  # the image re-derive Aether's WebKitGTK against the board-specific FFmpeg
  # (a from-source WebKit build) instead of reusing the verified generic
  # derivations.
  nixpkgs.overlays = lib.mkAfter [
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
