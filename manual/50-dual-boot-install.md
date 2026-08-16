# Dual boot

The upstream Omarchy ISO offers a free-space/full-disk installer. OmixOS does
not currently ship that installer and does not automate APFS, Windows, BitLocker,
or arbitrary partition changes. Dual boot is therefore unsupported and this
chapter is intentionally not an installation recipe.

The primary supported path is to flash the built Pi 4 image to a dedicated
removable medium. The macOS VM is non-destructive because it uses a separate
qcow2 disk. The Apple-silicon USB path does require a one-time Asahi UEFI setup
that changes the Mac's internal partition map; back up first and follow the
current upstream Asahi/NixOS guide exactly.

See [Getting Started](02-getting-started.md) and
[docs/install.md](../docs/install.md). Do not run the old `limine-scan`, free
space, or encryption instructions on an OmixOS target.
