# Testing

## Automated levels

Run on native `aarch64-linux`:

```bash
nix fmt -- --check
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
configuration. `system-smoke-vm` is an optional nested-QEMU headless boot test;
normal development does not depend on nested virtualization. `nix flake check`
also evaluates all three `nixosConfigurations`.

Native ARM results recorded on 2026-08-16:

- full package/check build passed for the runtime, font, exact Quickshell,
  headless theme activation, command boundary, and Hyprland Lua parser;
- `dev-aarch64` and `pi4` system closures built successfully;
- `dev-aarch64`, `pi4`, and `m2` evaluated from the locked inputs;
- physical/graphical and compressed-image results remain separately tracked in
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
