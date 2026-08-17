# Getting Started

OmixOS is installed as a NixOS configuration and a target-specific image, not
through the upstream Omarchy Arch ISO. The primary supported install is a
Raspberry Pi 4 image; the Mac workflows are a safe AArch64 VM and a separate
Apple-silicon live USB. There is no supported generic full-disk, dual-boot, or
x86-64 installer yet.

Follow the complete [OmixOS installation manual](../docs/install.md). It
covers native ARM64 builds, the verified `omixos-pi4.img.zst` artifact,
decompression before Balena Etcher, first-boot account initialization, and
validation commands.

## Raspberry Pi 4 in brief

On native AArch64 NixOS:

```bash
nix flake check
nix --accept-flake-config build .#packages.aarch64-linux.pi4-image
nix develop --command zstd --test result/sd-image/omixos-pi4.img.zst
nix develop --command \
  zstd --decompress --keep result/sd-image/omixos-pi4.img.zst
```

Flash the resulting raw `.img` to the whole removable device with Balena
Etcher. Never select a mounted partition or an uncertain disk. The write is
destructive; USB 3 SSD is preferred, while microSD is the simplest first boot.

The local `omix` session auto-starts. No password, Wi-Fi credential, or SSH key
is embedded. From a trusted local terminal, run the one-time helper:

```bash
sudo omixos-set-initial-password
```

The helper is narrowly authorized and refuses to run after the account has a
password. Configure Wi-Fi with NetworkManager and add SSH public keys through
a private NixOS host overlay before using remote deployment.

## macOS and Apple Silicon in brief

The macOS-hosted VM is non-destructive and provides a native AArch64 build
environment. The Apple-silicon live USB is a separate physical workflow that
requires a one-time Asahi UEFI setup; Apple firmware cannot boot Linux from an
external USB by itself. See [Mac support](44-mac-support.md) and the linked
installation guide for the exact commands.

The requested profile is implemented in the current tree: Ghostty is the
intended default terminal, `gtk-launch` is available, Neovim is in `core`,
Linear and Slack are present, and Basecamp/HEY are absent. Treat the final
generic AArch64 graphical acceptance as complete; it does not constitute
physical Pi/M2 acceptance evidence.

## Help if you're stuck

Check [troubleshooting](45-troubleshooting.md), then collect the diagnostics
listed in [the installation manual](../docs/install.md). Physical Pi 4 and M2
acceptance remains an explicit open gap.
