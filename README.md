# OmixOS

OmixOS ports the checked-out Omarchy **quattro** desktop to idiomatic NixOS.
The primary target is Raspberry Pi 4 (`aarch64-linux`); an Apple Silicon M2
host and a generic ARM64 development host share the same desktop modules.

The behavioral baseline is Omarchy commit
`f4f3d4c71a0a5c392b20ce05291531881a1b3bfe`. This is the current Quickshell
and Lua-Hyprland architecture. OmixOS does not substitute the historical
Waybar/Wofi desktop and does not emulate Pacman or AUR.

## Status

The software implementation and native ARM verification are complete,
including headless and graphical AArch64 system tests plus a flashable Pi
image. The graphical test boots the real greetd/UWSM/Hyprland/Quickshell
session and exercises the quattro shell, applications, live theme switching,
clipboard, screenshots, notifications, and PipeWire controls. Results are
tracked in [PORTING_STATUS.md](PORTING_STATUS.md), and unverified hardware
behavior is called out in [docs/known-gaps.md](docs/known-gaps.md). No physical
Pi 4 or M2 support claim is made until its acceptance list is run.

The `core` profile uses Ghostty by default, keeps Foot as a fallback, includes
Neovim and the GTK `gtk-launch` command, provides Linear and Slack web apps,
and omits Basecamp and all functional HEY integration. The app library can
search the pinned Nixpkgs revision, install an application into the user's Nix
profile, discover its desktop entry without logging out, launch it with
`gtk-launch`, and remove it again. VoxType dictation and the Aether app store
are included as native AArch64 integrations.

Display geometry is autodetected end to end: the kernel reads the EDID
preferred mode, Hyprland applies it (`mode = preferred`, `scale = auto`), and
the OmixOS `omarchy-hw-autoscale` session hook aligns the GTK/XWayland
`GDK_SCALE` with the monitor Hyprland actually detected — so a Pi 4 on a
1080p HDMI display gets 1x apps instead of upstream's hi-DPI laptop default.
Pinning a scale with `omarchy-hyprland-monitor-scaling` disables the hook
permanently.

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

## Apple Silicon development VM

On an Apple Silicon Mac, install QEMU and start a clean native AArch64 NixOS
installation on the repository's 128 GiB sparse VM disk:

```bash
brew install qemu
./scripts/macos-vm fetch
./scripts/macos-vm create
OMIXOS_VM_HEADLESS=1 ./scripts/macos-vm install
```

Follow the short partition/install sequence in [docs/macos.md](docs/macos.md),
then boot disk-only with `./scripts/macos-vm boot`. The same document covers
the reproducible ready-to-boot qcow2 and Apple-silicon live USB outputs. No Mac
disk is repartitioned by these VM commands.

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
- 31 of 425 command paths are explicit hardware/architecture/boot or
  destructive-development boundaries; the remaining 394 are preserved or
  adapted to NixOS.
- Some optional/proprietary quattro applications are unavailable on ARM64.
- A user password must be initialized with the image's one-time locked-account
  helper, and an SSH public key must be configured explicitly; neither is embedded.

See [docs/known-gaps.md](docs/known-gaps.md) for the maintained list.
