# Omarchy quattro compatibility

Status values are **portable**, **adapted**, **Nix-native**, **deferred**, and
**unsupported**. This is a living inventory based on the pinned checkout.

| Area / representative command | Source | Classification | Dependencies / adaptation | Status / test |
| --- | --- | --- | --- | --- |
| Shell IPC: `omarchy-shell` | `bin/omarchy-shell` | adapted | Wrapped `OMARCHY_PATH`; Quickshell `qs` IPC | Live shell ping passes in graphical ARM VM |
| Shell launch/restart | `bin/omarchy-launch-shell`, `omarchy-restart-shell` | adapted | Quickshell, systemd journal, Hyprland | Greetd/UWSM launch and shell continuity verified; explicit restart still manual |
| Menu and selectors | `omarchy-menu*` | adapted | Quickshell IPC, jq, Perl | Root menu IPC and layer verified graphically |
| Bar control | `omarchy-bar*` | portable | Shell IPC and writable `shell.json` | `omarchy-bar` layer verified graphically |
| Notifications | `omarchy-notification-*` | adapted | Quickshell notification service, libnotify | IPC, `notify-send`, and notification layer verified |
| Lock UI | shell `plugins/lock` | adapted | Declarative `omarchy-lock-password` PAM service | Configured; auth test pending |
| Theme selection/rendering | `omarchy-theme-set*` | adapted | Immutable built-ins, writable XDG state | Tokyo Night seed and live Catppuccin switch verified |
| Background selection | `omarchy-theme-bg*`, shell background plugin | adapted | Writable background symlink/cache | Writable resolved background state verified after live switch |
| Clipboard | `omarchy-clipboard-*`, shell plugin | adapted | wl-clipboard, jq, setpriv | Wayland copy/paste round trip passes |
| Screenshot | `omarchy-capture-screenshot` | adapted | grim, slurp, Hyprland, wl-clipboard | Wayland PNG capture passes; Pi cursor/VC4 test pending |
| Terminal launch/default | `omarchy-launch-terminal`, `omarchy-default-terminal` | adapted | Ghostty default, Foot fallback, xdg-terminal-exec, one-time preference migration | Ghostty maps successfully through the default-terminal path in graphical ARM VM |
| Browser launch/default | `omarchy-launch-browser`, `omarchy-default-browser` | adapted | Chromium's NixOS desktop ID, XDG handlers, `/run/current-system/sw` | Metadata test and mapped Chromium window pass |
| App library and web apps | desktop entries, `omarchy-launch-webapp` | adapted | GTK 3 supplies `gtk-launch`; NixOS Chromium desktop ID; user-manager launch | Linear and Slack launch through `gtk-launch`; Basecamp/HEY absent, including HEY handler/hotkeys |
| User package lifecycle | `omarchy-pkg-install/add/drop/remove/list/present/missing`, app-library removal | Nix-native | Searches the flake-pinned Nixpkgs revision and owns entries in the user's Nix profile | Live search, install, same-session desktop discovery, `gtk-launch`, app-library removal, and absence checks pass with XTerm |
| VoxType dictation | `omarchy-voxtype-*`, F9 and Super+Ctrl+X bindings | adapted | VoxType 0.7.4, offline base.en model, GTK4 OSD, user service | Daemon/model/OSD/status and remove/reinstall binding lifecycle pass graphically; physical microphone test pending |
| Aether store | `aether`, package map | adapted | Verified upstream 4.28.0 ARM64 release wrapped for NixOS | Native ARM build and live add/launch/remove lifecycle pass |
| Quattro native utilities | Omawrite, Omacalc, Omacut desktop entries | portable | Native Qt packages from pinned upstream inputs | All three build and launch as compositor-visible ARM64 clients |
| File manager | `omarchy-launch-nautilus*` | portable | Nautilus, UDisks/GVfs | Nautilus maps successfully in graphical ARM VM |
| Audio controls | `omarchy-audio-*` | portable | PipeWire/WirePlumber, pamixer | Live `wpctl` session path passes; hardware audio test pending |
| Network panels/helpers | `omarchy-network-*` | adapted | NetworkManager, qrencode | Configured; Pi test pending |
| Bluetooth panels/helpers | `omarchy-bluetooth-*` | adapted | BlueZ and Quickshell Bluetooth API | Configured; Pi test pending |
| Brightness | `omarchy-brightness-*` | adapted | brightnessctl; Apple/DDC variants remain hardware-specific | Generic path packaged; target tests pending |
| Reboot/shutdown | `omarchy-system-*` | portable | systemd/logind | Packaged; physical test pending |
| `omarchy update` and `omarchy-update-*` | `bin/` | Nix-native | Prints flake/generation workflow; never runs Pacman | Output and locked-update status tests pass |
| `omarchy-version` | `bin/omarchy-version` | Nix-native | Reports quattro source SHA | Implemented in runtime smoke |
| Version channel/package age | `omarchy-version-channel`, `omarchy-version-pkgs` | Nix-native | Reports the Nix channel model and current generation build time | Implemented; command test |
| Package queries | `omarchy-pkg-present/missing/list` | adapted | Executable/desktop/package-map checks plus owned user-profile state | Implemented and exercised before and after live installs/removals |
| Package install/remove and AUR labels | `omarchy-pkg-*`, `omarchy-install-*` | Nix-native/adapted | Pinned Nixpkgs search and per-user Nix profiles; catalog installers map native ARM packages or browser apps | Live application lifecycle passes; unavailable/x86-only selections return explicit reasons |
| Channels | `omarchy-channel-*` | Nix-native | Flake lock replaces Pacman channels | Stable channel reporting and no-op selection implemented |
| Arch migrations | `omarchy-migrate*`, `migrations/` | Nix-native | No pending Arch migrations; generations own system state | Safe response implemented; `--pending` reports none |
| Arch system provisioning | `omarchy-apply-*`, `omarchy-provision-*` | Nix-native | NixOS/Home Manager modules and activation seed | Arch paths disabled |
| Limine/Plymouth/SDDM refresh | `omarchy-refresh-*` | unsupported initially | Hardware host and greetd own boot/login | Safe stub packaged |
| Hibernation and hardware mutation | setup/toggle/hardware commands | deferred | Must be target modules after physical reproduction | Mutating paths disabled |
| Browser chrome retint | `omarchy-theme-set-browser` | deferred | Upstream mutates root-owned `/etc` Chromium policy; NixOS hook is a safe no-op | Shell/theme switching continues; browser chrome parity pending |
| Gaming/Windows VM | install/remove/VM commands | deferred | v0.1 non-goal; ARM availability varies | Disabled |
| Diagnostics | `omarchy-debug` | Nix-native | Local system/kernel/Hyprland/service/graphics/audio/network report | ARM command test passes; never uploads automatically |

The original source scripts remain attributable inside the source input, but
commands that could mutate an Arch system are replaced in the built runtime.
The pinned source exposes exactly 425 `omarchy*` command entry points. The
curated runtime removes the HEY mail handler and adds `omarchy-pkg-list`, so it
also exposes 425: 31 are explicit unsupported boundaries tied to absent Pi
hardware, x86-only runtimes, Arch package development, Plymouth, hibernation,
or destructive factory provisioning. The other 394 are preserved, adapted,
or replaced with Nix-native behavior.
`checks.aarch64-linux.command-boundary` asserts these counts,
lints every port-owned wrapper, executes representative blocked and adapted
paths, and rejects any direct Pacman, Yay/Paru, mkinitcpio, or Limine mutation
that re-enters the built command surface. A source-pin update therefore forces
an explicit command-boundary re-audit.
