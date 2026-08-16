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
| App library and web apps | desktop entries, `omarchy-launch-webapp` | adapted | GTK 3 supplies `gtk-launch`; NixOS Chromium desktop ID; user-manager launch | Linear launches through `gtk-launch`; Slack entry verified; Basecamp/HEY absent, including HEY handler/hotkeys |
| File manager | `omarchy-launch-nautilus*` | portable | Nautilus, UDisks/GVfs | Nautilus maps successfully in graphical ARM VM |
| Audio controls | `omarchy-audio-*` | portable | PipeWire/WirePlumber, pamixer | Live `wpctl` session path passes; hardware audio test pending |
| Network panels/helpers | `omarchy-network-*` | adapted | NetworkManager, qrencode | Configured; Pi test pending |
| Bluetooth panels/helpers | `omarchy-bluetooth-*` | adapted | BlueZ and Quickshell Bluetooth API | Configured; Pi test pending |
| Brightness | `omarchy-brightness-*` | adapted | brightnessctl; Apple/DDC variants remain hardware-specific | Generic path packaged; target tests pending |
| Reboot/shutdown | `omarchy-system-*` | portable | systemd/logind | Packaged; physical test pending |
| `omarchy update` and `omarchy-update-*` | `bin/` | Nix-native | Prints flake/generation workflow; never runs Pacman | Output and locked-update status tests pass |
| `omarchy-version` | `bin/omarchy-version` | Nix-native | Reports quattro source SHA | Implemented in runtime smoke |
| Version channel/package age | `omarchy-version-channel`, `omarchy-version-pkgs` | Nix-native | Reports the Nix channel model and current generation build time | Implemented; command test |
| Package queries | `omarchy-pkg-present/missing` | adapted | Best-effort executable presence, no package DB mutation | Implemented; imperfect for package-only names |
| Package install/remove and AUR | `omarchy-pkg-*`, `omarchy-install-*` | unsupported | Disabled; configure Nix packages declaratively | Safe stub packaged |
| Channels | `omarchy-channel-*` | unsupported | Flake lock replaces Pacman channels | Safe stub packaged |
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
curated runtime intentionally removes the HEY mail handler, so 424 remain: 131
are explicit safe-disabled stubs, 13 have port-owned Nix-native/adapted
replacements, and 280 are preserved or patched for the NixOS runtime.
`checks.aarch64-linux.command-boundary` asserts these counts,
lints every port-owned wrapper, executes representative blocked and adapted
paths, and rejects any direct Pacman, Yay/Paru, mkinitcpio, or Limine mutation
that re-enters the built command surface. A source-pin update therefore forces
an explicit command-boundary re-audit.
