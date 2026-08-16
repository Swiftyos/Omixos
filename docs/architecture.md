# Architecture

OmixOS has one hardware-independent desktop and separate hardware hosts:

```text
Omarchy quattro source input (immutable, pinned)
                 |
       omarchy-runtime package
                 |
     +-----------+------------+
     |                        |
NixOS module          Home Manager module
services/session      writable state seeding
     |                        |
     +-----------+------------+
                 |
       shared Omarchy desktop
          /       |       \
 dev ARM VM     Pi 4      M2/Asahi
 generic       VC4/RPi    Apple hardware
```

## Immutable runtime

`packages/omarchy-runtime.nix` installs the pinned source under
`$out/share/omarchy` and wraps commands with `OMARCHY_PATH` plus declared
runtime dependencies. Built-in shell code, themes, templates, applications,
and default configuration remain in the Nix store.

Arch-mutating commands are replaced at package time by explicit NixOS
boundaries. No fake Pacman layer exists.

## Writable user state

The Home Manager module copies defaults only when the destination is absent.
It never makes mutable Omarchy paths store symlinks. In particular:

- `~/.config/omarchy/plugins/` stays writable.
- `~/.config/omarchy/themes/` and backgrounds stay writable.
- `~/.config/hypr/` is seeded once and remains user-editable.
- `~/.config/uwsm/` and the default terminal preference are seeded once.
- `~/.local/state/omarchy/current/` contains generated active theme state.
- Existing files survive later activations.

Home Manager also sources the upstream Bash runtime, declares the default
Chromium MIME handlers, and installs Nix-native user services for crash
watching, pre-suspend locking, and internal-monitor recovery. NixOS owns the
keyring, PAM, network, Bluetooth, audio, portal, and power services.

## Hardware layers

`hosts/pi4` imports maintained Raspberry Pi 4 base, VC4 display, and Bluetooth
modules. `hosts/m2` imports the maintained Apple Silicon module. Neither
hardware policy appears in the shared module, and `aarch64-linux` is never
treated as synonymous with a particular board.

## Profiles

`core` contains the compositor, Quickshell, terminal, browser, file manager,
clipboard/screenshot/audio/network tools, fonts, and runtime. `workstation`
adds development and larger GUI/TUI tools. Optional features are independent
flags so an unavailable proprietary application cannot break the ARM desktop.
