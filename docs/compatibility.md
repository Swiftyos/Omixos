# Omarchy quattro compatibility

Status values are **portable**, **adapted**, **Nix-native**, **deferred**, and
**unsupported**. This is a living inventory based on the pinned checkout.

| Area / representative command | Source | Classification | Dependencies / adaptation | Status / test |
| --- | --- | --- | --- | --- |
| Shell IPC: `omarchy-shell` | `bin/omarchy-shell` | adapted | Wrapped `OMARCHY_PATH`; Quickshell `qs` IPC | Packaged; headless help/build smoke pending |
| Shell launch/restart | `bin/omarchy-launch-shell`, `omarchy-restart-shell` | adapted | Quickshell, systemd journal, Hyprland | Packaged; graphical test pending |
| Menu and selectors | `omarchy-menu*` | adapted | Quickshell IPC, jq, Perl | Packaged; graphical test pending |
| Bar control | `omarchy-bar*` | portable | Shell IPC and writable `shell.json` | Packaged; graphical test pending |
| Notifications | `omarchy-notification-*` | adapted | Quickshell notification service, libnotify | Packaged; graphical test pending |
| Lock UI | shell `plugins/lock` | adapted | Declarative `omarchy-lock-password` PAM service | Configured; auth test pending |
| Theme selection/rendering | `omarchy-theme-set*` | adapted | Immutable built-ins, writable XDG state | Headless smoke defined; graphical reload pending |
| Background selection | `omarchy-theme-bg*`, shell background plugin | adapted | Writable background symlink/cache | Packaged; graphical test pending |
| Clipboard | `omarchy-clipboard-*`, shell plugin | adapted | wl-clipboard, jq, setpriv | Packaged; graphical test pending |
| Screenshot | `omarchy-capture-screenshot` | adapted | grim, slurp, Hyprland, wl-clipboard | Packaged; Pi cursor/VC4 test pending |
| Terminal launch/default | `omarchy-launch-terminal`, `omarchy-default-terminal` | adapted | foot, xdg-terminal-exec, seed-only writable preference | Packaged; graphical test pending |
| Browser launch/default | `omarchy-launch-browser`, `omarchy-default-browser` | adapted | Chromium's NixOS desktop ID, XDG handlers, `/run/current-system/sw` | Wrapper/desktop metadata test passes; graphical launch pending |
| File manager | `omarchy-launch-nautilus*` | portable | Nautilus, UDisks/GVfs | Packaged; graphical test pending |
| Audio controls | `omarchy-audio-*` | portable | PipeWire/WirePlumber, pamixer | Configured; hardware test pending |
| Network panels/helpers | `omarchy-network-*` | adapted | NetworkManager, qrencode | Configured; Pi test pending |
| Bluetooth panels/helpers | `omarchy-bluetooth-*` | adapted | BlueZ and Quickshell Bluetooth API | Configured; Pi test pending |
| Brightness | `omarchy-brightness-*` | adapted | brightnessctl; Apple/DDC variants remain hardware-specific | Generic path packaged; target tests pending |
| Reboot/shutdown | `omarchy-system-*` | portable | systemd/logind | Packaged; physical test pending |
| `omarchy update` and `omarchy-update-*` | `bin/` | Nix-native | Prints flake/generation workflow; never runs Pacman | Implemented; output test pending |
| `omarchy-version` | `bin/omarchy-version` | Nix-native | Reports quattro source SHA | Implemented in runtime smoke |
| Package queries | `omarchy-pkg-present/missing` | adapted | Best-effort executable presence, no package DB mutation | Implemented; imperfect for package-only names |
| Package install/remove and AUR | `omarchy-pkg-*`, `omarchy-install-*` | unsupported | Disabled; configure Nix packages declaratively | Safe stub packaged |
| Channels | `omarchy-channel-*` | unsupported | Flake lock replaces Pacman channels | Safe stub packaged |
| Arch migrations | `omarchy-migrate*`, `migrations/` | Nix-native | No pending Arch migrations; generations own system state | Safe no-op/pending implementation |
| Arch system provisioning | `omarchy-apply-*`, `omarchy-provision-*` | Nix-native | NixOS/Home Manager modules and activation seed | Arch paths disabled |
| Limine/Plymouth/SDDM refresh | `omarchy-refresh-*` | unsupported initially | Hardware host and greetd own boot/login | Safe stub packaged |
| Hibernation and hardware mutation | setup/toggle/hardware commands | deferred | Must be target modules after physical reproduction | Mutating paths disabled |
| Gaming/Windows VM | install/remove/VM commands | deferred | v0.1 non-goal; ARM availability varies | Disabled |
| Diagnostics | `omarchy-debug` | Nix-native | Local system/kernel/Hyprland/service/graphics/audio/network report | ARM command test passes; never uploads automatically |

The original source scripts remain attributable inside the source input, but
commands that could mutate an Arch system are replaced in the built runtime.
`checks.aarch64-linux.command-boundary` lints every port-owned wrapper and
executes representative blocked and adapted paths.
