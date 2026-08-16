# Porting status

Checked items mean implemented and verified at the level stated. Evaluation,
generic graphical testing, and physical testing are intentionally distinct.

## Upstream baseline

- [x] Source repository, remote, branch, SHA, and cleanliness recorded
- [x] Contributor and architecture/theming/testing/update documentation read
- [x] Quattro shell, command, package, and Hyprland inventory started
- [x] Upstream clone left clean and unmodified

## Flake

- [x] ARM64-first flake structure implemented
- [x] `flake.lock` generated
- [x] Formatting passes
- [x] `nix flake check` passes on native ARM64
- [x] `dev-aarch64`, `pi4`, and `m2` evaluate

## Runtime package

- [x] Immutable source layout and wrapped `OMARCHY_PATH` implemented
- [x] Arch-mutating command boundary implemented
- [x] Headless runtime/theme smoke check defined
- [x] Runtime package builds on `aarch64-linux`
- [x] Smoke check passes

## Quickshell

- [x] Current upstream `shell/` packaged; no Waybar/Wofi substitution
- [x] Official quattro Quickshell revision identified and pinned exactly
- [x] Package revision/source compatibility recorded
- [x] Exact pinned Quickshell and shell wrapper build on `aarch64-linux`
- [ ] Shell starts and remains running in ARM VM
- [ ] Bar/menu/notifications/IPC verified

## Hyprland

- [x] Shared Hyprland/UWSM/portal module implemented
- [x] Upstream Lua config seeded as writable user configuration
- [x] Lua config parses with the pinned Hyprland (`config ok`)
- [ ] Generic ARM graphical session verified

## Themes

- [x] Immutable built-ins plus writable user overlay/state design implemented
- [x] Seed-only activation implemented
- [x] Headless Tokyo Night activation check passes
- [ ] Live theme/background reload verified

## CLI

- [x] Initial command compatibility inventory recorded
- [x] Nix-native update/version/migration boundaries implemented
- [x] Pacman/AUR/system-mutating paths disabled
- [x] Command-boundary/ShellCheck test passes on native ARM64
- [x] NixOS-aware browser/desktop-entry and diagnostic wrappers implemented
- [ ] Core CLI behavior verified in ARM session
- [ ] Full important-command inventory completed

## Core applications

- [x] Terminal, Chromium, Nautilus, clipboard, screenshot, audio/network tools declared
- [x] Omarchy icon font packaged and registered
- [x] Every essential package evaluates on ARM64
- [ ] Terminal/browser/file manager launch verified
- [ ] Clipboard/screenshots/audio controls verified

## Dev VM

- [x] Generic AArch64 host declared with no Pi/Asahi hardware policy
- [x] System closure builds on native ARM64
- [x] Headless NixOS system VM smoke test passes under QEMU TCG
- [ ] VM boot and desktop acceptance completed

## Pi image

- [x] Pi 4 base/VC4/Bluetooth hardware boundary declared
- [x] Flashable image output exposed
- [x] Pi system closure builds with the maintained BCM2711 kernel
- [x] Compressed Pi image builds and passes integrity/partition inspection

## Pi physical

- [ ] Cold boot, HDMI, VC4/Hyprland, and Quickshell
- [ ] Terminal, browser, file manager, clipboard, screenshots, notifications
- [ ] Audio, Ethernet, Wi-Fi, Bluetooth, keyboard, and mouse
- [ ] Reboot, shutdown, remote deploy, and rollback
- [ ] Idle CPU/memory and latency measurements recorded

## M2

- [x] Separate Asahi host imports the same shared desktop
- [x] Configuration evaluates with locked hardware input
- [ ] Physical M2 acceptance completed

## Deferred

- [ ] x86_64-linux
- [ ] SDDM parity
- [ ] Heavy media/recording/gaming/Windows VM stack
- [ ] Broader proprietary application parity

## Known blockers

- No physical Pi 4 or bare-metal M2 is connected to this work session.
- Physical support claims therefore remain blocked after software build checks.
