# Unattended and image-based installs

The upstream `cidata`/cloud-init Omarchy ISO installer is not implemented in
OmixOS. There is no supported JSON credential drive, unattended Pacman
provisioner, or fleet installer in this port.

For repeatable installs, build the declarative target artifact and deploy a
known host configuration:

```bash
nix flake check
nix --accept-flake-config build .#packages.aarch64-linux.pi4-image
sudo nixos-rebuild switch --flake .#pi4 --target-host omix@<pi-host> --use-remote-sudo
```

The Pi image intentionally carries no password, SSH key, or Wi-Fi secret. On a
local first boot, initialize the locked account with
`sudo omixos-set-initial-password`; for remote deployment, add an SSH public
key declaratively in a private host overlay. Credentials belong outside the
repository.

For the Apple Silicon development workflow, use the documented macOS-hosted
AArch64 VM and its dedicated `macos-vm` host. The Apple-silicon live USB is a
separate physical/recovery artifact and requires an Asahi UEFI environment.
See the [installation manual](../docs/install.md).

Do not attach the old `cidata` drive, run the old Proxmox ISO recipe, or treat
the upstream unattended installer as an OmixOS feature.
