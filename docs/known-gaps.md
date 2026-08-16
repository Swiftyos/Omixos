# Known gaps

## Blocking support claims

- The locked flake evaluates and its package checks, generic host closure, and
  Pi host closure build on native ARM64. The compressed image remains a
  separate gate.
- The exact quattro-pinned Quickshell builds with Networking, Bluetooth, PAM,
  Polkit, PipeWire, UPower, Hyprland, and Wayland session-lock modules enabled;
  their live QML behavior still requires a graphical acceptance session.
- Hyprland 0.55.4 reports `config ok` for the exact seeded Lua configuration;
  compositor startup and rendering still require a real graphical session.
- The compressed Pi image must build, then boot on a physical Pi 4.
- Pi VC4, HDMI, audio, Ethernet, Wi-Fi, Bluetooth, input, reboot, shutdown,
  remote deploy, rollback, and performance remain untested.
- The M2 host evaluates by design but remains physically untested.
- The evaluable M2 host does not embed Apple's non-redistributable peripheral
  firmware; a real host overlay must provide it and enable extraction.

## Intentional NixOS differences

- Pacman, Yay, AUR, ALPM hooks, Arch migrations, channels, ISO installer,
  Limine scripts, and mutable `/etc` provisioning are not ported.
- Their mutating command entry points fail safely or report the NixOS
  generation workflow.
- Greetd is used for the initial lightweight login path; SDDM theme parity is
  deferred.
- `omarchy update` documents flake updates and rebuilds instead of mutating the
  checkout automatically.

## Application gaps

- Heavy media, gaming, Windows VM, commercial, and x86-only applications are
  outside Pi v0.1.
- `omarchy-pkg-present/missing` is a best-effort command check for menu guards,
  not a Nix package database API.
- The locked ARM package set required a native Chromium build because no
  substitute was available in the configured caches during verification.
- The Omarchy icon font is packaged and registered; live glyph rendering still
  belongs to graphical acceptance testing.

## Security/first boot

- No password or SSH key is embedded. The auto-started local user must run the
  image's narrowly authorized, locked-account-only password initializer from a
  trusted console before PAM unlock and general sudo are usable.
- Wi-Fi credentials belong to NetworkManager state or a private deployment
  secret, never this repository.
