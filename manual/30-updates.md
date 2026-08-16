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

`omarchy update` is retained as a compatibility command. It explains or
dispatches the Nix-native workflow; it never runs `pacman`, `yay`, AUR
transactions, Arch migrations, or mutable channel changes.

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
