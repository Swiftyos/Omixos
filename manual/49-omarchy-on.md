# OmixOS on supported targets

OmixOS is intentionally narrow in its first release. The supported targets
are:

- **Raspberry Pi 4:** primary physical target, 64-bit ARM, with a flashable
  image built from the maintained Raspberry Pi hardware modules.
- **Apple Silicon M2:** secondary target, using the maintained Asahi/NixOS
  hardware stack. Physical acceptance and private peripheral firmware setup
  remain pending.
- **Native AArch64 development VM:** generic ARM host for evaluation and
  graphical smoke tests.
- **macOS-hosted AArch64 VM:** safe QEMU installation/build environment on an
  Apple Silicon Mac.

See [Getting Started](02-getting-started.md) and the
[installation manual](../docs/install.md) for commands. Other machines,
Steam Decks, Intel Macs, Windows/VirtualBox/Parallels guests, and x86-64 are
not acceptance targets. Do not substitute an old Arch Omarchy guide or a
third-party `omarchy-nix` project for this repository's pinned implementation.
