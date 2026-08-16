# OmixOS

OmixOS ports the checked-out Omarchy **quattro** desktop to idiomatic NixOS.
The primary target is Raspberry Pi 4 (`aarch64-linux`); an Apple Silicon M2
host and a generic ARM64 development host share the same desktop modules.

The behavioral baseline is Omarchy commit
`30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec`. This is the current Quickshell
and Lua-Hyprland architecture. OmixOS does not substitute the historical
Waybar/Wofi desktop and does not emulate Pacman or AUR.

## Status

The reproducible module/package foundation is under active implementation.
Evaluation and package results are tracked in [PORTING_STATUS.md](PORTING_STATUS.md),
and unverified hardware behavior is called out in [docs/known-gaps.md](docs/known-gaps.md).
No physical Pi 4 or M2 support claim is made until its acceptance list is run.

## Development

On an AArch64 NixOS development machine:

```bash
git clone git@git.paradiso.home:craig/OmixOS.git
cd OmixOS
nix flake check
nix build .#packages.aarch64-linux.omarchy-runtime
nix build .#packages.aarch64-linux.omarchy-shell
nix build .#nixosConfigurations.dev-aarch64.config.system.build.toplevel
```

To test changes against the provided local Omarchy checkout without changing
the committed source pin:

```bash
nix build \
  --override-input omarchy-src path:../omarchy \
  .#packages.aarch64-linux.omarchy-runtime
```

## Raspberry Pi 4

Build the flashable image on native ARM64:

```bash
nix --accept-flake-config build .#packages.aarch64-linux.pi4-image
```

The resulting `result/sd-image/` artifact can be flashed only through an
explicit operator action. See [docs/pi4.md](docs/pi4.md) for first boot,
credentials, remote deployment, and rollback.

After first boot, ordinary iteration uses remote rebuilds rather than reflashing:

```bash
sudo nixos-rebuild switch --flake .#pi4 --target-host <user>@<pi-host>
```

## Updates and rollback

Update inputs and create a new NixOS generation explicitly:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#pi4
```

Use the boot menu for an earlier generation or run:

```bash
sudo nixos-rebuild switch --rollback
```

`omarchy update` explains this Nix-native flow. It never runs Arch package
commands. Theme switching and user plugins remain writable user operations.

## Major known gaps

- Physical Pi 4 boot, VC4, audio, Wi-Fi, Bluetooth, and performance tests are pending.
- Physical M2/Asahi tests are pending.
- Upstream Arch install, package, migration, channel, and boot commands are disabled.
- Some optional/proprietary quattro applications are unavailable on ARM64.
- A user password must be initialized with the image's one-time locked-account
  helper, and an SSH public key must be configured explicitly; neither is embedded.

See [docs/known-gaps.md](docs/known-gaps.md) for the maintained list.
