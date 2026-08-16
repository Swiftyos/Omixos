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
      url = "github:basecamp/omarchy/30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec";
      flake = false;
    };

    # Exact source revision in omacom-io/omarchy-pkgs for this quattro
    # baseline. The tagged Nixpkgs 0.3.0 source is twenty commits older.
    quickshell-src = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell?rev=28771c7c74b42e20afca0b1b63980cb46515537c";
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

      pi4Configuration = nixos-raspberrypi.lib.nixosSystem {
        inherit nixpkgs;
        specialArgs = { inherit inputs; };
        modules = commonModules ++ [ ./hosts/pi4 ];
      };

      pi4ImageConfiguration = nixos-raspberrypi.lib.nixosInstaller {
        inherit nixpkgs;
        specialArgs = { inherit inputs; };
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
          omarchySrc = omarchy-src;
        })
        // {
          quickshell = prev.quickshell.overrideAttrs (_old: {
            version = "0.3.0.r20.g28771c7";
            src = quickshell-src;
          });
        };

      nixosModules.default = {
        imports = [ ./modules/nixos ];
        nixpkgs.overlays = [ self.overlays.default ];
      };

      homeManagerModules.default = import ./modules/home-manager;

      nixosConfigurations = {
        dev-aarch64 = devConfiguration;
        pi4 = pi4Configuration;
        m2 = m2Configuration;
      };

      packages.${system} = {
        inherit (pkgs) omarchy-fonts omarchy-runtime omarchy-shell;
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
      };

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nil
          nixfmt-tree
          shellcheck
        ];
      };
    };
}
