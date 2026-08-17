# OmixOS installation manual

This is the installation guide for the current OmixOS NixOS port. The primary
target is a Raspberry Pi 4 (64-bit ARM); the Apple Silicon M2 path is
secondary. OmixOS does not currently ship the upstream Omarchy Arch ISO
installer, a generic full-disk installer, or a supported x86-64 installation
path.

The checked-in `manual/` tree adapts the full upstream Omarchy manual to this
port and clearly labels behavior that is still pending physical validation.
Use this installation guide together with the target-specific
[Pi 4 guide](pi4.md) and [macOS/Apple-silicon guide](macos.md).

## Before you start

Build and evaluate OmixOS on a native `aarch64-linux` NixOS machine. The
Apple Silicon macOS VM is the supported way to obtain that build environment
from an M2 Mac. Have the following ready:

- a recent checkout of this repository and a working Nix installation with
  flakes enabled;
- a Raspberry Pi 4, removable microSD/USB storage, display, and wired or USB
  keyboard for the primary hardware test; and
- Balena Etcher (or another deliberate raw-image writer) when preparing Pi
  storage.

The repository's software checks and image builds have passed on native ARM64.
No physical Pi 4 or bare-metal M2 acceptance has passed yet; the gaps are
listed at the end of this guide.

## Raspberry Pi 4: primary install

### Build and verify the image

From the repository on native ARM64, evaluate the flake and build the Pi
image:

```bash
nix flake check
nix --accept-flake-config build .#packages.aarch64-linux.pi4-image
find result/sd-image -maxdepth 1 -type f -print
```

The output is normally a compressed image such as
`result/sd-image/omixos-pi4.img.zst`. Verify the compressed artifact, then
expand a copy for Etcher. Balena Etcher accepts the raw `.img`, not the
`.img.zst` file:

```bash
nix develop --command zstd --test result/sd-image/omixos-pi4.img.zst
nix develop --command \
  zstd --decompress --keep result/sd-image/omixos-pi4.img.zst
file result/sd-image/omixos-pi4.img
sha256sum result/sd-image/omixos-pi4.img.zst result/sd-image/omixos-pi4.img
```

The image build and partition/integrity inspection are verified. Flashing is
an operator action and is intentionally not automated.

### Flash with Etcher

1. Insert the microSD card or USB/SSD and identify its whole removable disk in
   Etcher. On macOS, use `diskutil list`; confirm capacity, external/removable
   status, and partition names immediately before writing.
2. Select the decompressed `omixos-pi4.img` as the image. Select the whole
   removable device, not one of its partitions.
3. Start the write and verification, then eject the device safely.

Writing the wrong disk destroys its contents. USB 3 SSD is preferred for
sustained Nix workloads; microSD is the simplest first-boot medium.

### First boot and credentials

Boot the Pi from the flashed medium with Ethernet connected if possible. The
local graphical `omix` session starts automatically. The image intentionally
contains no reusable password, Wi-Fi credential, SSH key, or root password.
From a trusted local terminal, initialize the account once:

```bash
sudo omixos-set-initial-password
```

That helper is the only passwordless sudo rule on the image. It works only
while the `omix` shadow entry is locked and refuses to run after the password
has been initialized. Normal sudo and PAM unlock then use the password you
choose.

Ethernet uses DHCP. Configure Wi-Fi from NetworkManager in the local session.
For remote deployment, add an SSH public key in a private host overlay under
`users.users.omix.openssh.authorizedKeys.keys` and rebuild; no key is embedded
in the published image.

### Validate the running Pi

After the first boot, run the checks relevant to the hardware that is present:

```bash
systemctl --failed
systemctl --user --failed
hyprctl version
hyprctl monitors
wpctl status
nmcli device
bluetoothctl show
```

The graphical ARM VM has already exercised the greetd/UWSM/Hyprland/Quickshell
session, application launch, clipboard, screenshots, notifications, theme
switching, and PipeWire controls. These commands still need to be observed on
the physical Pi before those hardware behaviors are considered supported.

For ordinary iteration after first boot, deploy a new generation over SSH:

```bash
sudo nixos-rebuild switch \
  --flake .#pi4 \
  --target-host omix@<pi-host> \
  --use-remote-sudo
```

Remote sudo remains password-protected; OmixOS does not install a broad
`NOPASSWD: ALL` rule. If a generation is bad, select the previous generation
from the boot menu or use:

```bash
sudo nixos-rebuild switch --rollback
```

## Apple Silicon M2 paths

There are two different Mac workflows. They must not be conflated:

1. **macOS-hosted AArch64 VM:** safe development and installation proof; it
   does not repartition the Mac.
2. **Apple Silicon live USB / native M2:** physical hardware work; it requires
   a one-time Asahi UEFI environment because Apple firmware does not natively
   boot Linux from an external USB.

### Safe macOS-hosted VM

On macOS, install QEMU and create a clean sparse VM disk:

```bash
brew install qemu
./scripts/macos-vm fetch
./scripts/macos-vm create
OMIXOS_VM_HEADLESS=1 ./scripts/macos-vm install
```

The installer boots a 128 GiB qcow2 disk. Follow the exact `/dev/vda`
partition and mount sequence in [macos.md](macos.md), copy the repository into
`/mnt/etc/omixos`, and install the dedicated host:

```bash
nixos-install --flake /mnt/etc/omixos#macos-vm \
  --no-root-passwd --no-channel-copy \
  --option experimental-features 'nix-command flakes'
```

Power off the installer and boot from disk:

```bash
./scripts/macos-vm boot
```

The VM starts the local `omix` session with a locked account. Initialize its
password once with `sudo omixos-set-initial-password`. From a repository
checkout inside the VM, the focused acceptance check is:

```bash
sudo ./scripts/verify-macos-vm
```

A reproducible ready-to-boot VM image can instead be built on native ARM64:

```bash
nix build .#macos-vm-image -o result-macos-vm
cp -n result-macos-vm/*.qcow2 omixos-macos-vm.qcow2
chmod u+w omixos-macos-vm.qcow2
OMIXOS_VM_DISK="$PWD/omixos-macos-vm.qcow2" \
  OMIXOS_VM_VARS="$PWD/omixos-macos-vm-vars.fd" \
  ./scripts/macos-vm boot
```

The VM artifact and live-session checks are software/VM evidence only; they
are not evidence that an M2's display, GPU, keyboard, trackpad, networking, or
audio works on bare metal.

### Apple Silicon live USB and native M2

Build the USB image on native ARM64 (the VM above can be used as the builder):

```bash
nix build .#apple-silicon-usb-image --print-build-logs
```

The result is `result/iso/omixos-apple-silicon-usb-*.iso`. Copy it to macOS
and flash the whole external disk, never a partition:

```bash
diskutil list
diskutil unmountDisk /dev/diskN
sudo dd if=result/iso/omixos-apple-silicon-usb-*.iso \
  of=/dev/rdiskN bs=8m
sync
diskutil eject /dev/diskN
```

Replace `diskN` only after rechecking the removable device. The `dd` command
is destructive.

Before this USB can boot on an M2, use the current
`nixos-apple-silicon` UEFI standalone instructions and the official Asahi
installer to create the UEFI environment, including the documented recoveryOS
permissive-security step. Back up first: this one-time setup changes the
internal partition map and is deliberately not automated by OmixOS. The live
image extracts the Mac-specific, non-redistributable peripheral firmware from
the internal Asahi EFI system partition; it is not embedded in the ISO.

The native `.#m2` host also needs the generated hardware/filesystem details
from that Asahi installation and a private copy of `vendorfw/firmware.cpio`
with peripheral-firmware extraction enabled. The checked-in M2 configuration
evaluates without those private machine inputs, but it is not a completed
physical installation recipe.

On macOS, verify copied VM/USB artifacts before testing them physically:

```bash
./scripts/verify-macos-artifacts omixos-macos-vm.qcow2 \
  omixos-apple-silicon-usb.iso
```

## Profile status and gaps

The latest requested application profile is: Ghostty as the default terminal,
Basecamp and HEY launchers absent, Linear and Slack web apps present, and
Neovim in the core profile. VoxType 0.7.4, its offline `base.en` model and GTK4
OSD are included, and Aether 4.28.0 is available through the Nix-native user
package lifecycle. The native AArch64 system test verifies the packages,
desktop entries, MIME defaults, migrations, and headless add/present/drop
flow. The graphical ARM test verifies Ghostty through the default-terminal
path, VoxType service/OSD/binding lifecycle, Aether and the native Qt apps,
Linear and Slack through `gtk-launch`, and a live pinned-Nixpkgs
search/install/same-session launch/app-library removal cycle. This manual does
not claim physical Pi or M2 verification.

The following physical checks remain open:

- Pi 4 cold boot, HDMI/VC4 rendering, Quickshell, input, audio, Ethernet,
  Wi-Fi, Bluetooth, reboot/shutdown, remote deployment, rollback, and resource
  measurements;
- M2/Asahi display, GPU acceleration, keyboard, trackpad, Wi-Fi, Bluetooth,
  audio, suspend/resume, firmware extraction, and actual USB boot; and
- heavy/proprietary applications, gaming, Windows VM integration, and x86-64.

Do not describe a physical target as supported until its acceptance list has
been run and the result recorded in `PORTING_STATUS.md`.
