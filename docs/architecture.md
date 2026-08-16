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
       /       /      \          \
 dev ARM VM  macOS VM  Pi 4    M2/Asahi + USB
 generic     virtio    VC4/RPi  Apple hardware
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
modules. `hosts/m2` imports the maintained Apple Silicon module, while
`hosts/apple-silicon-usb` layers the same desktop onto its live installer.
`hosts/macos-vm` is a generic virtio/EFI guest and carries no Apple hardware
policy. None of these hardware decisions appears in the shared module, and
`aarch64-linux` is never treated as synonymous with a particular board.

## Profiles

`core` contains the compositor, Quickshell, Ghostty (with Foot fallback),
Chromium, Nautilus, Neovim, GTK launcher support, clipboard/screenshot/audio/
network tools, fonts, and runtime. It exposes Linear and Slack as browser apps
while excluding Basecamp and HEY. `workstation` adds development and larger
GUI/TUI tools. Optional features are independent flags so an unavailable
proprietary application cannot break the ARM desktop.
