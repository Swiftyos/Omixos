# Testing

## Automated levels

Run on native `aarch64-linux`:

```bash
nix fmt -- --ci
nix flake check
nix build .#checks.aarch64-linux.command-boundary
nix build .#checks.aarch64-linux.hyprland-config
nix build .#checks.aarch64-linux.system-smoke-vm
nix build .#checks.aarch64-linux.graphical-smoke-vm
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

`graphical-smoke-vm` boots a normal AArch64 NixOS VM under QEMU TCG with a
virtio GPU and Mesa software rendering, then follows the production login path
through greetd, UWSM, Hyprland, and `omarchy-launch-shell`. It verifies a live
monitor and Quickshell IPC, bar/menu/notification layers, a Catppuccin theme
switch from the seeded Tokyo Night state, Ghostty through the actual
`xdg-terminal-exec` default, Nautilus, and Linear through `gtk-launch` as an
isolated Chromium window. It also verifies a Wayland clipboard round trip, a
real PNG screenshot, notification delivery, PipeWire/WirePlumber control,
required QML helpers, and zero failed user units. Software rendering is
test-only: the test prefixes `gtk-launch` with `OMIXOS_GRAPHICAL_TEST=1` so
Chromium uses software rendering and a non-interactive password store. Normal
sessions retain Chromium's GPU and keyring behavior. Physical VC4 acceptance
remains separate.

Native ARM results recorded on 2026-08-16:

- full `nix flake check` passed, including the runtime, font, exact Quickshell,
  headless theme activation, command boundary, Hyprland Lua parser, and
  AArch64 headless system VM boot test;
- the standalone AArch64 graphical smoke check passed end to end in 384.56
  seconds, covering the real quattro shell and core desktop workflows listed
  above, including a direct `gtk-launch Linear.desktop` command that produced
  a compositor-visible Chromium window;
- the 425-command source surface was inventoried; the built runtime exposes
  424 after intentionally removing the HEY mail handler, with the exact 131
  safe-disabled commands enforced and direct Arch mutation scanned out;
- `dev-aarch64` and `pi4` system closures built successfully;
- `dev-aarch64`, `pi4`, and `m2` evaluated from the locked inputs;
- the refreshed Pi image built as a 3,220,490,826-byte zstd artifact with
  uncompressed size 9,475,538,944 bytes and SHA-256
  `5c31dec2f269036aeddce89cee7ab7d69a1d31d2f872f168db2a4b15db6284f6`;
- the copied raw image matched the builder's decompressed stream at SHA-256
  `7bb83df3ba22f47a81bc743b45fe0347a14b71f15e7473a835b6f53ee5d79080`;
- `zstd -t`, MBR inspection, the 1 GiB FAT32 firmware partition, the 7.8 GiB
  Linux partition, firmware/device-tree/U-Boot installation, and FAT fsck
  passed;
- image sudoers inspection confirmed ordinary wheel access requires a password
  and only `omixos-set-initial-password` has its narrow `NOPASSWD` rule;
- physical and generic graphical results remain separately tracked in
  `PORTING_STATUS.md`.

## CI readiness

The repository exposes formatting, flake/module/package evaluation, custom
wrapper checks, headless boot, and graphical boot through `nix flake check` on
`aarch64-linux`. The Forgejo repository reported zero registered Actions
runners on 2026-08-16, so no unverified runner label is hard-coded. Once a
trusted native ARM runner or builder is registered, that command is the CI job
boundary; Pi and Mac image builds can remain scheduled/manual jobs because of
their size.

## Generic ARM graphical acceptance

The automated graphical VM now verifies Hyprland, Quickshell stability, bar,
menu, notifications, terminal, Chromium, Nautilus, live theme/background
state, clipboard, screenshots, PipeWire controls, and failed user units. PAM
lock authentication and hardware-specific rendering, input, audio, network,
and Bluetooth behavior remain physical acceptance items.

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

## macOS VM and Apple-silicon USB evidence

The generic macOS/HVF path was installed from the pinned official NixOS 26.05
AArch64 installer onto a fresh GPT/EFI+ext4 qcow2, then rebooted disk-only,
switched to the exact final `macos-vm` configuration, and rebooted again.
`verify-macos-vm` passed with zero failed units; greetd, NetworkManager, D-Bus,
SSH, Hyprland, Wayland, the monitor, bar, shell, notifications, Docker, DRM,
and Omarchy revision `30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec` were all present. Temporary
builder credentials were removed or locked before the final image was trimmed
and powered off.

Artifacts verified on 2026-08-16 from OmixOS commit `749d451` (tree
`1121e2712d2a992e54410c2734a99ebf07b795af`):

- `omixos-macos-vm-reproducible.qcow2`: 10,928,783,360-byte file,
  128 GiB virtual size, SHA-256
  `10391573b82d6be7bfc257c283aa4fbab72abe6bbeb2e3f7cfecc3b60102067b`;
  `qemu-img check` passed and a disposable overlay reached the full graphical
  desktop through EDK2/HVF.
- `omixos-apple-silicon-usb.iso`: 2,751,907,840 bytes, SHA-256
  `bd68f72e95f4b56cdaf93b73bccefecc293137cff988ea93a15a5ce5c8951a6e`;
  the ISO label, `BOOTAA64.EFI`, GRUB configuration, EFI image, SquashFS, and
  version metadata passed structural verification, and EDK2/QEMU reached the
  graphical UEFI CD-ROM boot menu.

The qcow2 result is generic ARM VM evidence. The ISO result proves artifact
structure and EFI menu startup only. Neither is a physical Asahi/M2 hardware
acceptance result.
