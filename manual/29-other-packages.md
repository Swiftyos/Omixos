# Other packages

OmixOS does not provide the upstream Arch _Install > Package_, Pacman, or AUR
workflow. The immutable runtime lives in the Nix store and core/workstation
packages are declared in the flake. To add software, add a Nixpkgs package to a
host/profile or a private overlay, then build and switch a new generation:

```bash
nix flake check
sudo nixos-rebuild switch --flake .#pi4
```

The Pi 4 `core` profile contains the ARM-safe desktop, Chromium, Ghostty,
Neovim, and essential network/audio/file tools. The workstation profile adds
development tools; optional heavy, proprietary, gaming, and x86-only software
may remain unavailable. Do not claim an app is installed merely because its
upstream Quattro menu entry exists.

For the current profile, Linear and Slack are declarative web-app entries;
Basecamp and HEY launchers are absent. The generic ARM tests verify the
installed entries and launch Linear through `gtk-launch`.
