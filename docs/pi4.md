# Raspberry Pi 4

The Pi host is 64-bit ARM and imports the maintained `nixos-raspberrypi` Pi 4
base, VC4 display, and Bluetooth modules. OmixOS adds no speculative Mesa,
DRM, CMA, or cursor workaround before a physical failure is reproduced.

## Build and flash

On a native AArch64 NixOS builder:

```bash
nix flake check
nix --accept-flake-config build .#packages.aarch64-linux.pi4-image
find result/sd-image -maxdepth 1 -type f -print
```

Flashing is intentionally not automated. Verify the exact removable target,
unmount it, and use your preferred imaging tool explicitly. The operation
destroys the selected device. USB 3 SSD is recommended for sustained Nix use;
microSD remains the first-boot path.

The tested BalenaEtcher release accepts the raw `.img` but not the compressed
`.img.zst`. Expand it first without modifying the original artifact:

```bash
nix develop --command \
  zstd --decompress --keep result/sd-image/omixos-pi4.img.zst
```

Verify the decompressed size/hash, then select the whole removable device in
Etcher. Do not select a mounted partition or a disk identified only by its
current device number; confirm its external/removable status, capacity, and
partition names immediately before flashing.

## Credentials and first boot

The image embeds no password, Wi-Fi credential, SSH private key, or public
key. The local `omix` graphical session auto-starts. From a trusted local
console, initialize the user password before relying on PAM unlock or general
sudo access:

```bash
sudo omixos-set-initial-password
```

The image grants passwordless sudo to that exact helper only. It first verifies
that the `omix` shadow password is still locked; after a password is initialized
it refuses to run, so it cannot be used as a password-reset backdoor. There is
no general passwordless sudo rule and no reusable password in the image.

Add an SSH public key declaratively to `users.users.omix.openssh.authorizedKeys.keys`
in a private host overlay, then rebuild. Do not commit private keys.

Use NetworkManager from the local session to configure Wi-Fi. Ethernet uses
DHCP by default.

## Remote iteration

From the ARM development VM:

```bash
nix flake check
nix build .#nixosConfigurations.pi4.config.system.build.toplevel
sudo nixos-rebuild switch \
  --flake .#pi4 \
  --target-host omix@omixos-pi4.local \
  --use-remote-sudo
```

Remote sudo remains password-protected. Use an interactive deployment path or
a narrowly scoped deployment design; OmixOS does not add `NOPASSWD: ALL`.

## Rollback and diagnostics

Select the previous generation from the boot menu, or after a successful boot:

```bash
sudo nixos-rebuild switch --rollback
systemctl --failed
systemctl --user --failed
hyprctl version
hyprctl monitors
wpctl status
nmcli device
bluetoothctl show
```

The physical acceptance list is in [testing.md](testing.md). No item is marked
supported until it is observed on the real Pi.
