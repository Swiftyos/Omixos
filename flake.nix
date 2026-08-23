{
  description = "OmixOS: the Omarchy quattro desktop ported to NixOS, ARM64 first";

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep this input's own Nixpkgs pin. The Asahi stack may require revisions
    # newer than the primary stable package set; the host still consumes the
    # same hardware-independent OmixOS modules.
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/main";

    omarchy-src = {
      url = "github:basecamp/omarchy/f4f3d4c71a0a5c392b20ce05291531881a1b3bfe";
      flake = false;
    };

    # Upstream quattro moved from its temporary quickshell-git snapshot back to
    # the packaged 0.3.1 release, whose `kill` waits for the instance to exit.
    # Nixpkgs 26.05 still carries 0.3.0, so pin the v0.3.1 tag here.
    quickshell-src = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell?rev=1a4716cde794a59928d9d9fc15f2afc7a95de360";
      flake = false;
    };

    voxtype = {
      url = "github:peteonrails/voxtype/v0.7.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omawrite-src = {
      url = "github:omacom-io/omawrite/8f98892b26768236b2c20f4e637cf4b102d898bf";
      flake = false;
    };

    omacut-src = {
      url = "github:omacom-io/omacut/d1a63377a202fff2bc4205e94d2f39519a1d4071";
      flake = false;
    };

    omacalc-src = {
      url = "github:omacom-io/omacalc/dba63819810d0a3b1a0581f3bcafc9651dbfb85d";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixos-raspberrypi,
      nixos-apple-silicon,
      omarchy-src,
      quickshell-src,
      voxtype,
      omawrite-src,
      omacut-src,
      omacalc-src,
      ...
    }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };

      commonModules = [
        self.nixosModules.default
        home-manager.nixosModules.home-manager
        ./hosts/common.nix
      ];

      # runNixOSTest passes an already-instantiated, read-only package set.
      # `pkgs` above already contains the OmixOS overlay, so the VM imports the
      # implementation module directly instead of the public overlay wrapper.
      testModules = [
        ./modules/nixos
        home-manager.nixosModules.home-manager
        ./hosts/common.nix
      ];

      devConfiguration = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = commonModules ++ [ ./hosts/dev-aarch64 ];
      };

      macosVmConfiguration = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = commonModules ++ [ ./hosts/macos-vm ];
      };

      appleSiliconUsbConfiguration = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs nixos-apple-silicon; };
        modules = commonModules ++ [
          nixos-apple-silicon.nixosModules.apple-silicon-installer
          {
            hardware.asahi.pkgsSystem = system;
            nixpkgs.hostPlatform.system = system;
            nixpkgs.buildPlatform.system = system;
          }
          ./hosts/apple-silicon-usb
        ];
      };

      pi4Configuration = nixos-raspberrypi.lib.nixosSystem {
        inherit nixpkgs;
        specialArgs = {
          inherit inputs;
          omixosGenericPkgs = pkgs;
        };
        modules = commonModules ++ [ ./hosts/pi4 ];
      };

      pi4ImageConfiguration = nixos-raspberrypi.lib.nixosInstaller {
        inherit nixpkgs;
        specialArgs = {
          inherit inputs;
          omixosGenericPkgs = pkgs;
        };
        modules = commonModules ++ [
          ./hosts/pi4
          ./hosts/pi4/image.nix
        ];
      };

      m2Configuration = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs nixos-apple-silicon; };
        modules = commonModules ++ [ ./hosts/m2 ];
      };
    in
    {
      overlays.default =
        final: prev:
        (import ./packages {
          pkgs = final;
          # The primary pin now carries the cached AArch64 WebKitGTK 2.52.5
          # closure Aether needs, so a second Nixpkgs evaluation would only
          # duplicate the base library stack in every image.
          aetherPackage = final.callPackage ./packages/aether.nix { };
          omarchySrc = omarchy-src;
          nixpkgsRef = "github:NixOS/nixpkgs/${nixpkgs.rev}";
          inherit omawrite-src omacut-src omacalc-src;
        })
        // {
          quickshell = prev.quickshell.overrideAttrs (_old: {
            version = "0.3.1";
            src = quickshell-src;
          });
          voxtype = voxtype.packages.${final.system}.default;
          voxtype-osd-gtk4 = voxtype.packages.${final.system}.osd-gtk4;
          voxtype-model-base-en = final.fetchurl {
            name = "ggml-base.en.bin";
            url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
            hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
          };
        };

      nixosModules.default = {
        imports = [ ./modules/nixos ];
        nixpkgs.overlays = [ self.overlays.default ];
      };

      homeManagerModules.default = import ./modules/home-manager;

      nixosConfigurations = {
        dev-aarch64 = devConfiguration;
        macos-vm = macosVmConfiguration;
        apple-silicon-usb = appleSiliconUsbConfiguration;
        pi4 = pi4Configuration;
        m2 = m2Configuration;
      };

      packages.${system} = {
        inherit (pkgs)
          aether
          omarchy-fonts
          omarchy-runtime
          omarchy-shell
          omawrite
          omacut
          omacalc
          voxtype
          voxtype-osd-gtk4
          voxtype-model-base-en
          ;
        macos-vm-image = macosVmConfiguration.config.system.build.images.qemu-efi;
        apple-silicon-usb-image = appleSiliconUsbConfiguration.config.system.build.isoImage;
        pi4-image = pi4ImageConfiguration.config.system.build.sdImage;
        default = pkgs.omarchy-runtime;
      };

      checks.${system} = {
        inherit (pkgs) omarchy-fonts omarchy-runtime omarchy-shell;
        runtime-smoke = import ./tests/smoke {
          inherit pkgs;
          runtime = pkgs.omarchy-runtime;
        };
        command-boundary = import ./tests/command-boundary.nix {
          inherit pkgs;
          runtime = pkgs.omarchy-runtime;
        };
        hyprland-config = import ./tests/hyprland-config.nix {
          inherit pkgs;
          runtime = pkgs.omarchy-runtime;
        };
        system-smoke-vm = import ./tests/vm.nix {
          inherit pkgs testModules;
        };
        graphical-smoke-vm = import ./tests/graphical-vm.nix {
          inherit pkgs testModules;
        };
      };

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nil
          nixfmt-tree
          shellcheck
          zstd
        ];
      };
    };
}
