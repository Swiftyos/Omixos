# Testing

## Automated levels

Run on native `aarch64-linux`:

```bash
nix fmt -- --ci
nix flake check
nix build .#checks.aarch64-linux.command-boundary
nix build .#checks.aarch64-linux.hyprland-config
nix build .#checks.aarch64-linux.system-smoke-vm
nix build .#packages.aarch64-linux.omarchy-runtime
nix build .#packages.aarch64-linux.omarchy-shell
nix build .#nixosConfigurations.dev-aarch64.config.system.build.toplevel
nix build .#nixosConfigurations.pi4.config.system.build.toplevel
nix --accept-flake-config build .#packages.aarch64-linux.pi4-image
```

`runtime-smoke` verifies the pinned revision, required runtime assets, wrapped
version command, and a headless Tokyo Night theme activation into writable
state. `command-boundary` lints port wrappers and executes representative safe
failures, Python helpers, diagnostics, icons, and Nix-native update behavior.
`hyprland-config` asks the exact packaged Hyprland to parse the seeded Lua
configuration. `system-smoke-vm` boots AArch64 NixOS under QEMU TCG, activates
the D-Bus services, and verifies the runtime, writable seed state, desktop
defaults, command boundary, and enabled user units without requiring nested
KVM. `nix flake check` also evaluates all three `nixosConfigurations`.

Native ARM results recorded on 2026-08-16:

- full `nix flake check` passed, including the runtime, font, exact Quickshell,
  headless theme activation, command boundary, Hyprland Lua parser, and
  AArch64 system VM boot test;
- `dev-aarch64` and `pi4` system closures built successfully;
- `dev-aarch64`, `pi4`, and `m2` evaluated from the locked inputs;
- the Pi image built as a 3,181,608,784-byte zstd artifact with uncompressed
  size 9,486,565,376 bytes and SHA-256
  `6494880d2a5265e248ad911a58fd3b7b6182a0510d2a5becef0a2eee510d7e2d`;
- `zstd -t`, MBR inspection, the 1 GiB FAT32 firmware partition, the 7.8 GiB
  Linux partition, firmware/device-tree/U-Boot installation, and FAT fsck
  passed;
- image sudoers inspection confirmed ordinary wheel access requires a password
  and only `omixos-set-initial-password` has its narrow `NOPASSWD` rule;
- physical and graphical results remain separately tracked in
  `PORTING_STATUS.md`.

## Generic ARM graphical acceptance

In the M2 ARM VM verify Hyprland, Quickshell stability, bar, menu,
notifications, PAM lock, terminal, Chromium, Nautilus, themes, background,
clipboard, screenshots, PipeWire controls, and failed user units. Record exact
package versions and logs before marking them complete in `PORTING_STATUS.md`.

## Physical Pi acceptance record

No physical result has yet been recorded. A valid record must contain:

- OmixOS commit and `flake.lock` state
- Omarchy SHA
- Pi model/RAM/storage/display
- kernel, Hyprland, and Quickshell versions
- dated pass/fail result for boot, VC4, shell, apps, input, audio, Ethernet,
  Wi-Fi, Bluetooth, reboot, shutdown, remote deploy, and rollback
- idle CPU/memory, shell/compositor memory, startup, and menu latency

Pi and M2 results remain separate. Evaluation alone is never reported as
physical support.
