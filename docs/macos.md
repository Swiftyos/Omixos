# macOS VM and Apple-silicon USB

OmixOS has two distinct macOS paths:

- a safe QEMU virtual machine, which does not modify the Mac's disks; and
- an Apple-silicon live USB, which needs a one-time Asahi UEFI environment on
  the internal SSD because Apple firmware cannot boot Linux directly from USB.

The VM is the recommended first test.

The development host used for this work identifies as `Mac14,5`: the 2023
14-inch MacBook Pro with an Apple M2 Max (`T6021`). The current Asahi support
matrix lists the installer, internal display, GPU, keyboard, trackpad, Wi-Fi,
Bluetooth, speakers, microphones, webcam, brightness, and suspend support for
the M2 Pro/Max MacBook Pro. Touch ID remains unsupported.

## QEMU VM on Apple silicon

The reproducible ready-to-boot artifact is exposed as:

```console
nix build .#macos-vm-image -o result-macos-vm
cp -n result-macos-vm/*.qcow2 omixos-macos-vm.qcow2
chmod u+w omixos-macos-vm.qcow2
OMIXOS_VM_DISK="$PWD/omixos-macos-vm.qcow2" \
  OMIXOS_VM_VARS="$PWD/omixos-macos-vm-vars.fd" \
  ./scripts/macos-vm boot
```

Build that output on AArch64 NixOS; the clean VM installation described below
is one way to obtain that native build environment on macOS. Nix store outputs
are read-only, so boot the writable copy rather than the `result-macos-vm`
symlink itself.

### Clean installation proof

Install QEMU with Homebrew, then fetch and verify the pinned NixOS 26.05 ARM64
installer and create a fresh 128 GiB sparse disk:

```console
brew install qemu
./scripts/macos-vm fetch
./scripts/macos-vm create
OMIXOS_VM_HEADLESS=1 ./scripts/macos-vm install
```

At the installer console, partition only `/dev/vda`:

```console
sudo -i
parted --script /dev/vda mklabel gpt
parted --script /dev/vda mkpart ESP fat32 1MiB 1025MiB
parted --script /dev/vda set 1 esp on
parted --script /dev/vda mkpart root ext4 1025MiB 100%
mkfs.fat -F 32 -n EFI /dev/vda1
mkfs.ext4 -L nixos /dev/vda2
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot /mnt/etc
mount /dev/disk/by-label/EFI /mnt/boot
```

Make the repository available at `/mnt/etc/omixos` by copying a checkout into
the installer or cloning it there. Then install the dedicated VM host:

```console
nixos-install --flake /mnt/etc/omixos#macos-vm \
  --no-root-passwd --no-channel-copy \
  --option experimental-features 'nix-command flakes'
poweroff
```

Boot without the ISO:

```console
./scripts/macos-vm boot
```

The `omix` desktop auto-starts. Its account is initially locked and no reusable
password is embedded in the image. From the desktop, initialize it once with:

```console
sudo omixos-set-initial-password
```

Run `sudo ./scripts/verify-macos-vm` inside a repository checkout to check the
booted system, graphical session, bar, shell IPC, notification IPC, and pinned
Omarchy version.

### Recorded VM result

On 2026-08-16, using OmixOS commit `749d451` (tree
`1121e2712d2a992e54410c2734a99ebf07b795af`), the clean install above
completed from the pinned official NixOS 26.05 AArch64 ISO. The guest booted
from disk alone, applied the final
`macos-vm` generation, rebooted again, and passed `verify-macos-vm`: no failed
units; greetd, NetworkManager, D-Bus, SSH, Hyprland, Wayland, monitor, bar,
shell, notifications, Docker, and `/dev/dri/card0` plus `renderD128` were
healthy. The verified Omarchy revision was
`30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec`.

The final reproducible image is a 10,928,783,360-byte qcow2 with a 128 GiB
virtual size and SHA-256
`10391573b82d6be7bfc257c283aa4fbab72abe6bbeb2e3f7cfecc3b60102067b`.
`qemu-img check` passed, and an EDK2/HVF boot from a disposable overlay reached
the full graphical desktop. Temporary builder credentials were removed or
locked before the image was trimmed and powered off.

## Apple-silicon live USB

Build the live image on an AArch64 NixOS machine (the OmixOS VM can do this):

```console
nix build .#apple-silicon-usb-image --print-build-logs
```

Keep at least 100 GiB free on the macOS volume during the first native build.
The qcow2 is sparse, but the full Asahi kernel temporarily consumes more than
32 GiB in addition to the guest system and Nix store.

The result is `result/iso/omixos-apple-silicon-usb-*.iso`. It contains the full
OmixOS workstation desktop and the maintained `nixos-apple-silicon` kernel,
device trees, an AArch64 EFI loader for the existing m1n1/U-Boot chain, and
installer support. The live `omix` session has passwordless sudo because the
medium is an installer/recovery environment; root is locked and SSH is
disabled.

The image does not and legally cannot contain this Mac's proprietary peripheral
firmware. At live boot, the maintained installer module extracts that firmware
from the internal Asahi EFI system partition created for this OS.

Flash the ISO to the whole USB device, not a partition. First identify the exact
external disk with `diskutil list`; replacing `/dev/diskN` below with a wrong
identifier destroys the selected disk:

```console
diskutil unmountDisk /dev/diskN
sudo dd if=result/iso/omixos-apple-silicon-usb-*.iso \
  of=/dev/rdiskN bs=8m
sync
diskutil eject /dev/diskN
```

On macOS, press `Control-T` while `dd` runs to print progress.

### Required one-time boot setup

Apple-silicon firmware has no native external-storage boot path for Linux. Use
the current `nixos-apple-silicon` UEFI standalone guide and official Asahi
installer to create an **UEFI environment only**, then complete the documented
recoveryOS permissive-security step. This changes the internal partition map,
so make a current backup and follow the upstream guide exactly; OmixOS does not
automate that operation.

After the UEFI environment exists, shut down, insert the OmixOS USB, and select
that Asahi/UEFI OS from the Apple boot picker. U-Boot normally discovers the USB
EFI loader automatically. If an internal Linux system wins the boot order, stop
U-Boot autoboot and put `usb 0` first with `eficonfig`.

The live USB can be built and structurally verified in a VM, but display,
keyboard, trackpad, Wi-Fi, audio, suspend, and an actual USB boot remain physical
acceptance checks on the target MacBook Pro.

The 2026-08-16 artifact from commit `749d451` was 2,751,907,840 bytes with SHA-256
`bd68f72e95f4b56cdaf93b73bccefecc293137cff988ea93a15a5ce5c8951a6e`.
Verification found the `OMIXOS_USB` label, `BOOTAA64.EFI`, GRUB configuration,
EFI image, SquashFS, and version metadata, and EDK2/QEMU reached the graphical
UEFI CD-ROM menu. This does not claim physical Apple-driver or external-USB
boot; those still require the one-time internal Asahi UEFI environment and a
separately authorized removable target.

After copying both outputs to macOS, verify qcow2 integrity, its 128 GiB virtual
size, the ISO filesystem, and the standard AArch64 EFI loader with:

```console
./scripts/verify-macos-artifacts omixos-macos-vm.qcow2 \
  omixos-apple-silicon-usb.iso
```

Upstream references:

- [NixOS Apple Silicon UEFI standalone guide](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md)
- [Asahi open-OS boot interoperability](https://asahilinux.org/docs/platform/open-os-interop/)
- [Asahi M2-series feature matrix](https://asahilinux.org/docs/platform/feature-support/m2/)
- [Asahi USB-boot FAQ](https://asahilinux.org/docs/project/faq/)
