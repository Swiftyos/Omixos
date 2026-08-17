# Mac support

OmixOS has two distinct Apple Silicon workflows; they are not interchangeable:

1. a safe macOS-hosted native AArch64 QEMU VM for building and testing; and
2. an Apple-silicon live USB/native M2 path that requires a one-time Asahi UEFI
   environment before external Linux boot is possible.

The first is the recommended development/install proof. It does not
repartition the Mac. The second is physical hardware work and remains
unverified for display, GPU, keyboard, trackpad, Wi-Fi, Bluetooth, audio,
suspend, firmware extraction, and actual USB boot.

The VM and USB workflows are distinct: the VM is the supported non-destructive
macOS-hosted install/build path, while Apple Silicon USB boot requires Asahi
UEFI and is not a shortcut to the VM's validation results.

Follow the [OmixOS installation manual](../docs/install.md) and
[macOS hardware guide](../docs/macos.md). The VM flow is:

```bash
brew install qemu
./scripts/macos-vm fetch
./scripts/macos-vm create
OMIXOS_VM_HEADLESS=1 ./scripts/macos-vm install
```

The VM installer uses a 128 GiB sparse qcow2 disk and a dedicated
`#macos-vm` host. Initialize the locked `omix` account with
`sudo omixos-set-initial-password`, then run `sudo ./scripts/verify-macos-vm`
from a checkout inside the guest.

Build the separate USB image on native ARM64 with:

```bash
nix build .#apple-silicon-usb-image --print-build-logs
```

Flash the resulting ISO to the whole removable disk only after checking
`diskutil list`. Create the UEFI environment with the current
`nixos-apple-silicon`/Asahi instructions and back up first; OmixOS does not
automate that destructive internal partition setup. The image extracts
non-redistributable peripheral firmware from the internal Asahi EFI partition.
