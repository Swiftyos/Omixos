# Other packages

OmixOS does not provide the upstream Arch _Install > Package_, Pacman, or AUR
workflow. The immutable runtime lives in the Nix store. `omarchy-pkg-install`
searches the pinned Nixpkgs revision and installs a supported package into the
current user's Nix profile; `omarchy-pkg-add` accepts known aliases and
`omarchy-pkg-remove`/`omarchy-pkg-drop` remove user-installed entries. Core and
system packages remain declarative: add them to a host/profile or private
overlay, then build and switch a new generation:

```bash
nix flake check
sudo nixos-rebuild switch --flake .#pi4
```

The Pi 4 `core` profile contains the ARM-safe desktop, Chromium, Ghostty,
Neovim, and essential network/audio/file tools. The workstation profile adds
development tools; optional heavy, proprietary, gaming, and x86-only software
may remain unavailable. Do not claim an app is installed merely because its
upstream Quattro menu entry exists.

For the current profile, Linear and Slack are web-app entries; Basecamp and HEY
launchers are absent. After a profile transaction the menu refreshes, and the
same session can discover a desktop entry with `gtk-launch <desktop-id>`.
Aether 4.28.0 uses this profile lifecycle, while the native ARM
Omawrite/Omacut/Omacalc packages are declarative core entries. Unsupported Pi
ARM packages report their reason explicitly.
