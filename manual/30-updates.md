# Updates

OmixOS updates are Nix flake and NixOS generation operations. The immutable
Omarchy runtime, Quickshell package, NixOS modules, and profile packages are
built from pinned inputs; user themes, plugins, and selected configuration
remain writable Home Manager state.

From a native ARM64 checkout:

```bash
nix flake check
nix flake update                 # intentionally update inputs
sudo nixos-rebuild switch --flake .#pi4
```

For the development VM or M2 host, use the matching flake target (`dev-aarch64`,
`macos-vm`, or `m2`). Pi deployment can target the running board over SSH:

```bash
sudo nixos-rebuild switch \
  --flake .#pi4 \
  --target-host omix@<pi-host> \
  --use-remote-sudo
```

`omarchy update` is the NixOS adapter. It refreshes or clones the OmixOS source,
updates pinned flake inputs, builds the selected host, and switches a new NixOS
generation only after the build succeeds. It never runs `pacman`, `yay`, AUR
transactions, Arch migrations, or mutable channel changes.

Other formerly system-mutating menu routes have the same boundary-aware
adapters: `omarchy-dns` edits NetworkManager profiles, `omarchy-menu-timezone`
uses the NixOS/timedatectl system policy, service commands manage Tailscale and
Sunshine, and development-environment commands manage Mise state. These are
real NixOS integrations; they do not imply arbitrary Arch package mutation.

## Generations and rollback

Each successful switch creates a NixOS generation. Select an earlier one at
boot, or roll back the active profile:

```bash
sudo nixos-rebuild switch --rollback
```

This is not an Omarchy/Limine snapshot and does not restore arbitrary files in
`/home`. Keep user data in backups or version-controlled Home Manager state.

## Verification and gaps

Run `nix flake check` and the target closure/image builds before deploying. The
headless and graphical AArch64 VM checks exercise the Quattro shell and core
workflows. Pi boot, VC4, audio, networking, peripherals, deployment, rollback,
and M2/Asahi hardware remain physical acceptance gaps.
