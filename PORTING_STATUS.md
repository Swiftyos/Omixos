# Porting status

Checked items mean implemented and verified at the level stated. Evaluation,
generic graphical testing, and physical testing are intentionally distinct.

## Upstream baseline

- [x] Source repository, remote, branch, SHA, and tracked-tree status recorded
- [x] Contributor and architecture/theming/testing/update documentation read
- [x] Quattro shell, complete command surface, package, and Hyprland inventory recorded
- [x] Upstream tracked tree left unmodified; untracked macOS metadata preserved

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
- [x] Shell starts and remains running in graphical ARM VM
- [x] Bar/menu/notifications/IPC verified in graphical ARM VM

## Hyprland

- [x] Shared Hyprland/UWSM/portal module implemented
- [x] Upstream Lua config seeded as writable user configuration
- [x] Lua config parses with the pinned Hyprland (`config ok`)
- [x] Generic ARM graphical session verified under AArch64 QEMU TCG

## Themes

- [x] Immutable built-ins plus writable user overlay/state design implemented
- [x] Seed-only activation implemented
- [x] Headless Tokyo Night activation check passes
- [x] Live theme/background switch and shell continuity verified

## CLI

- [x] Initial command compatibility inventory recorded
- [x] Nix-native update/version/migration boundaries implemented
- [x] Pacman/AUR mutations replaced by pinned Nix user-profile or generation workflows
- [x] Command-boundary/ShellCheck test passes on native ARM64
- [x] NixOS-aware browser/desktop-entry and diagnostic wrappers implemented
- [x] Core CLI behavior verified in ARM system and graphical sessions
- [x] All 425 quattro source commands inventoried and exposed (HEY handler removed; `omarchy-pkg-list` added)
- [x] Exact 31-command unsupported boundary and Arch-mutation scan enforced; 394 commands remain preserved/adapted/Nix-native
- [x] Search/install/list/presence/remove package lifecycle implemented against pinned Nixpkgs and the user profile

## Core applications

- [x] Ghostty default, Foot fallback, Chromium, Nautilus, Neovim, `gtk-launch`, clipboard, screenshot, and audio/network tools declared
- [x] Linear and Slack web apps installed and launched through `gtk-launch`; Basecamp and functional HEY integrations removed
- [x] VoxType daemon, offline model, GTK OSD, status, bindings, and enable/disable lifecycle integrated
- [x] Aether ARM64 package plus install/launch/remove lifecycle integrated
- [x] Omawrite, Omacalc, and Omacut build and launch as native ARM64 Qt applications
- [x] Omarchy icon font packaged and registered
- [x] Every essential package evaluates on ARM64
- [x] Terminal/browser/file manager launch verified as mapped Wayland clients, including direct `gtk-launch` for Linear and Slack
- [x] Clipboard, PNG screenshot, and PipeWire control paths verified

## Dev VM

- [x] Generic AArch64 host declared with no Pi/Asahi hardware policy
- [x] System closure builds on native ARM64
- [x] Headless NixOS system VM smoke test passes under QEMU TCG
- [x] VM boot and generic ARM desktop acceptance completed

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
- [x] Generic macOS/HVF AArch64 VM clean-install, disk-only reboot, and graphical acceptance passed
- [x] Reproducible qcow2 integrity and graphical boot verified
- [x] Apple-silicon USB ISO structure and AArch64 EFI boot menu verified
- [ ] Physical M2 acceptance completed

## Quattro f4f3d4c7 re-pin (2026-08-23)

- [x] `omarchy-src` re-pinned from `30f7a060` to checkout HEAD `f4f3d4c7` (39 commits)
- [x] Quickshell floor moved to the packaged 0.3.1 (`kill` waits for exit), pinned by tag
- [x] webp theme backgrounds decode in the shell via the qtimageformats plugin
- [x] Theme-staging writability re-anchored around the hardened repo-theme staging path
- [x] Theme re-stage security migration (1787481315) mirrored into activation
- [x] New Remove > AI surface wired through Nix-native `omarchy-pkg-drop` (Ollama override)
- [x] Package map covers grok-bot, t3code-bin, ollama-vulkan, cliamp, minecraft-launcher, and the native Qt trio; x86-only rows curated as unsupported
- [x] `fastfetch` and `/etc/fastfetch/config.jsonc` provided for the About animation
- [x] Download Video stack (yt-dlp, mpv, ffmpeg) moved into the core profile
- [x] Command surface re-inventoried: 433 upstream + `omarchy-pkg-list` + `omarchy-hw-autoscale` - HEY handler = 434

## Display autodetection

- [x] `omarchy-hw-autoscale` aligns GDK_SCALE with the monitor scale Hyprland detected at session start
- [x] Hook runs from the session-start provisioning path; manual scale pins disable it permanently
- [x] Live session environment refreshed (`systemctl --user set-environment`, D-Bus activation env)
- [x] Pi firmware config confirmed EDID-driven (`disable_overscan=1`, `display_auto_detect=1`, full KMS)
- [x] macOS VM preferred mode configurable via `OMIXOS_VM_XRES`/`OMIXOS_VM_YRES` (cocoa cannot resize the guest)
- [x] Autoscale rewrite and environment verified in the graphical ARM VM

## Image slimming (2026-08-23)

- [x] Pi system closure reduced from 8.69 GiB to 5.04 GiB (-42%)
- [x] Full linux-firmware replaced by the Broadcom 43455 wireless firmware the board uses
- [x] speech-dispatcher/espeak/flite/mbrola accessibility voices (~800 MiB) removed
- [x] Pi Mesa rebuilt with only V3D/VC4 GL and Broadcom Vulkan; LLVM (532 MiB) no longer in the closure
- [x] Second Nixpkgs evaluation for Aether removed; WebKitGTK 2.52.5 now substitutes from the primary pin
- [x] Embedded Nixpkgs source copy (registry/NIX_PATH, ~200 MiB) dropped
- [x] Fonts limited to the quattro surface (JetBrainsMono Nerd Font variant, Liberation, Noto + CJK sans + emoji, DejaVu)
- [x] gvfs built without SMB, ModemManager disabled, manual/info/-doc outputs and stray vim removed
- [x] Firmware FAT partition 1 GiB -> 512 MiB
- [x] Trade-offs documented in docs/known-gaps.md

## User-bug fixes (override audit, 2026-08-23)

- [x] `omarchy-update` uses the Nix >= 2.19 `flake update --flake` form and rejects unknown hosts
- [x] `omarchy-update-available` no longer lights a phantom badge on fresh installs, cannot hang the bar on a dead remote, and counts real behind-commits
- [x] VoxType keybindings guard on the binary as well as the disable toggle (F9 no longer swallowed when dictation is off)
- [x] Menu package guards parse all six package-map columns (webapp/store rows were invisible)
- [x] `omarchy-pkg-add` continues past per-package failures; preinstall restore reports failures and keeps the removed marker
- [x] `omarchy-pkg-drop` resolves real profile element keys, tolerates missing elements, and always cleans recorded state
- [x] `omarchy-remove-launcher-entry` handles store-mode profile entries (Aether) without jq crashes
- [x] `omarchy-version` reports the built runtime's actual upstream revision
- [x] Browser defaults auto-install missing browsers through the floating-terminal flow like upstream
- [x] DNS switching survives per-connection failures and keeps the menu checkmark honest
- [x] fzf/gum cancels are no-ops in package pickers; multi-word package search works
- [x] Webapp launches use `--collect --quiet` transient units (no failed-unit debris)

## Deferred

- [ ] x86_64-linux
- [ ] SDDM parity
- [ ] Heavy media/recording/gaming/Windows VM stack
- [ ] Broader proprietary application parity

## Known blockers

- Physical Pi 4 and bare-metal M2 acceptance have not been run.
- Physical support claims therefore remain open after software/VM build checks.
