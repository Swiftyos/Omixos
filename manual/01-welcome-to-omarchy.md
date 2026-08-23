# Welcome to OmixOS!

OmixOS is the current NixOS port of the Omarchy **quattro** desktop. It keeps
the Hyprland, Quickshell, keyboard-first workflow, themes, shell plugins, and
command surface, while replacing Arch's mutable package/install machinery with
declarative NixOS and Home Manager configuration.

The runtime is pinned to upstream Quattro revision
`f4f3d4c71a0a5c392b20ce05291531881a1b3bfe`. This manual preserves the useful
Quattro interaction guide, but installation, updates, packages, boot, and
hardware claims are OmixOS-specific.

The supported starting point is a Raspberry Pi 4 (`aarch64-linux`). An
Apple-silicon M2 is a secondary target, with a safe macOS-hosted AArch64 VM for
development and a separate Asahi/UEFI live-USB path for physical testing. The
software desktop is exercised in ARM virtual machines, but physical Pi and M2
acceptance is still pending.

Start with the [OmixOS installation manual](../docs/install.md), not the
upstream Arch ISO instructions in the old chapters of this manual. Once the
desktop is running, the navigation, shell, themes, hotkeys, and customization
chapters below describe the Quattro user experience.

OmixOS is an [omakase](https://manuals.omamix.org/3/omacom/76/omakase-computing)
desktop: a focused set of tools rather than an app store or a generic Linux
distribution. The ARM64 core includes Chromium, Neovim, Ghostty, Nautilus,
Hyprland, Quickshell, and the Omarchy runtime. Workstation-only and
architecture-limited applications are intentionally separated from the Pi
profile.

This isn't just a grab bag of packages, though. It's a complete system designed
with both aesthetics and productivity in mind. Because a _beautiful_ system is
a _motivating_ system, and productivity has always been [downstream from
motivation](https://world.hey.com/dhh/beautiful-motivations-6fef7c73). The
system profile is declared in the flake, so unsupported optional software does
not silently turn into an Arch/AUR dependency.

The current intended application profile has Ghostty as the default terminal,
Neovim in core, Linear and Slack web apps, and no Basecamp or HEY launchers.
That profile and the generic AArch64 graphical workflow have passed automated
acceptance; physical Raspberry Pi acceptance remains separate.

It's true that developing an eye for the beauty of a TUI-heavy, theme-delighted, tiling-window-managed system like Omarchy can be an acquired taste. But that's why you're here, isn't it? To experience something a little outside of your comfort zone? To embark on a little bit of an adventure into a new way of working with computers? I hope so.

OmixOS isn't like Windows and it's not like macOS either. It's not trying to be
as familiar as possible. It's trying to be beautiful and _better_. Embrace the
Linux-ness of it all. Manually editing some user config files, sure. Heavy on
the terminal, definitely.

Let's get started with the basics.
