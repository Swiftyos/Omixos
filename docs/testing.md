# Testing

## Automated levels

Run on native `aarch64-linux`:

```bash
nix fmt -- --ci
nix flake check
nix build .#checks.aarch64-linux.version-alignment
nix build .#checks.aarch64-linux.command-boundary
nix build .#checks.aarch64-linux.hyprland-config
nix build .#checks.aarch64-linux.hyprland-lua-runtime
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
configuration — and only to parse it: `--verify-config` runs headless, where
`hl.get_active_monitor()` answers nil and every monitor-dependent code path
early-returns, so it proves nothing about what happens once a session has a
display. That gap once shipped a config that parsed cleanly and then raised
"attempt to index a nil value" on the first monitor event of every real boot.
Two checks close it. `hyprland-lua-runtime` executes the whole config through
a simulated session — monitor hotplug, focus hops, reserved-area changes,
timer bodies, reload with a live monitor, monitor expiry — against a strict
mock of the Lua API surface extracted at build time from the pinned Hyprland's
own source, so config code touching API the shipped compositor lacks fails in
the check with the same error a user would see. `version-alignment` guards the
relationships that made that bug possible in the first place: the primary
nixpkgs lock entry must pin an exact rev and match what evaluation resolves,
every configuration (including the Pi image composed through
nixos-raspberrypi's builder) must run the same Hyprland as the flake checks
test, and that Hyprland must satisfy the omarchy quattro floor of 0.56.
`system-smoke-vm` boots AArch64 NixOS under QEMU TCG, activates
the D-Bus services, and verifies the runtime, writable seed state, desktop
defaults, command boundary, and enabled user units without requiring nested
KVM. `nix flake check` also evaluates all three `nixosConfigurations`.

`graphical-smoke-vm` boots a normal AArch64 NixOS VM under QEMU TCG with a
virtio GPU and Mesa software rendering, then follows the production login path
through greetd, UWSM, Hyprland, and `omarchy-launch-shell`. It asks the
compositor itself for `hyprctl configerrors` right after the session comes up
and again after the autoscale/theme/dictation reloads, because Hyprland keeps
running behind its red error bar and every functional assertion can pass while
the session is visibly broken. It verifies a live
monitor and Quickshell IPC, bar/menu/notification layers, a Catppuccin theme
switch from the seeded Tokyo Night state, Ghostty through the actual
`xdg-terminal-exec` default, VoxType's daemon/model/GTK4 OSD and binding
lifecycle, Aether's user-profile add/launch/remove lifecycle, Omawrite,
Omacalc, Omacut, Nautilus, and both Linear and Slack through `gtk-launch`. It
also performs a real pinned-Nixpkgs search for XTerm, installs it into the user
profile, discovers and launches its desktop entry in the same session, removes
it through the app-library ownership path, and proves that it is gone. Finally,
it verifies a Wayland clipboard round trip, a real PNG screenshot, notification
delivery, PipeWire/WirePlumber control, required QML helpers, and zero failed
user units. Software rendering is
test-only: the test prefixes `gtk-launch` with `OMIXOS_GRAPHICAL_TEST=1` so
Chromium uses software rendering and a non-interactive password store. Normal
sessions retain Chromium's GPU and keyring behavior. Physical VC4 acceptance
remains separate.

Native ARM results recorded on 2026-08-17:

- full `nix flake check` passed, including the runtime, font, exact Quickshell,
  headless theme activation, command boundary, Hyprland Lua parser, and
  AArch64 headless system VM boot test;
- the final standalone AArch64 graphical smoke check passed end to end in 661.02
  seconds, covering the real quattro shell and the package, application,
  dictation, theme, clipboard, screenshot, notification, and audio-control
  workflows listed above;
- the 425-command source surface was inventoried; the built runtime exposes
  425 after replacing the removed HEY mail handler with `omarchy-pkg-list`;
  the exact 31 unsupported commands are enforced, leaving 394 preserved,
  adapted, or Nix-native commands, with direct Arch mutation scanned out;
- `dev-aarch64` and `pi4` system closures built successfully;
- `dev-aarch64`, `pi4`, and `m2` evaluated from the locked inputs;
- the refreshed Pi image built as a 3,876,648,015-byte zstd artifact with
  uncompressed size 12,935,139,328 bytes and SHA-256
  `7119e7af1da9460ab0da8afc28a8e0c67ee4a10e1ceba149cae6f14c83fbf9c4`;
- the copied raw image matched the builder's decompressed stream at SHA-256
  `5465aa62424f8d635af8cd0dcea48e58d1f19006a849ee7ed0a7ce8c169ad2b9`;
- `zstd -t`, MBR inspection, the 1 GiB FAT32 firmware partition, the 11.04 GiB
  Linux partition, firmware/device-tree/U-Boot installation, and FAT fsck
  passed;
- image sudoers inspection confirmed ordinary wheel access requires a password
  and only `omixos-set-initial-password` has its narrow `NOPASSWD` rule;
- physical and generic graphical results remain separately tracked in
  `PORTING_STATUS.md`.

Native ARM results recorded on 2026-08-23, after the quattro `f4f3d4c7`
re-pin, the display-autodetection feature, and the override bug-fix sweep:

- full `nix flake check` passed on the re-pinned tree, including the runtime,
  fonts, Quickshell 0.3.1, headless theme activation, command boundary,
  Hyprland Lua parser (with the new Quake console config), the AArch64
  headless system VM, and the full graphical acceptance VM;
- the graphical VM additionally verified the new display autodetection end to
  end: Hyprland reported monitor scale 1 on the virtio GPU,
  `omarchy-hw-autoscale` rewrote the seeded `GDK_SCALE` 2 default to 1 in
  `~/.config/hypr/monitors.lua`, refreshed the systemd user environment, and
  recorded its marker; it also verified webp background staging with writable
  store-derived theme state, the silent update badge on uninitialized
  checkouts, hidden Extra Themes without git themes, perl UTF-16 clipboard
  decoding, and the pinned `/etc/fastfetch` About layout;
- the 433-command upstream surface was re-inventoried; the built runtime
  exposes 434 after replacing the removed HEY mail handler with
  `omarchy-pkg-list` and adding the OmixOS `omarchy-hw-autoscale` command;
  the exact 31 unsupported commands are unchanged;
- `pi4` system closure built successfully from the locked inputs;
- after the same-day image slimming (full linux-firmware -> Pi wireless
  firmware, speech stack removed, LLVM-free V3D/VC4 Mesa, single Nixpkgs
  evaluation, no embedded Nixpkgs source, curated fonts, 512 MiB firmware
  partition) the `pi4` closure measured 5.04 GiB, down from 8.69 GiB;
- the slim Pi image built as a 2,223,267,331-byte zstd artifact with SHA-256
  `4a98563eb2e5f3f9c55cf9b69fad41562625c1d80aa1cd334129d8f3129fd578`;
- the copied artifact matched the builder's hash, passed `zstd -t`, and
  decompressed to a 7,808,258,048-byte raw image with SHA-256
  `a858dfa5c4dd1b99201a50cfaa2ee346ba5ae690bc46e47f23d45ce636bdf40e`, whose
  MBR carries the 512 MiB FAT32 firmware partition and the bootable 6.76 GiB
  Linux partition.

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
menu, notifications, Ghostty, Chromium web apps, Nautilus, Aether, the native
Qt applications, VoxType service/OSD/bindings, live user-package
install/discovery/launch/removal, theme/background state, clipboard,
screenshots, PipeWire controls, and failed user units. PAM lock authentication,
real microphone transcription, and hardware-specific rendering, input, audio,
network, and Bluetooth behavior remain physical acceptance items.

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
