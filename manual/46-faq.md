# FAQ

### How do I switch between keyboard layouts?

Edit `~/.config/hypr/input.lua` and configure `kb_layout`/`kb_options`. The
Quickshell bar shows the active layout when more than one is configured.

### How do I change the clock format?

Right-click the clock or use the shell command:

```bash
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

### How do I change networking or DNS?

Use NetworkManager (`nmcli`/`nmtui`) or the shell network panel. Persistent
system policy belongs in the NixOS host configuration. See [networking](35-networking.md).

### How do I change capture locations?

Set `OMARCHY_SCREENSHOT_DIR` or `OMARCHY_SCREENRECORD_DIR` in a writable
`~/.config/uwsm/env.d/` file, create the destination, and start a new session.

### Is printing enabled?

Printing is disabled in the current Pi, VM, M2, and USB profiles. Enable CUPS
declaratively in a private host configuration if required; the upstream
interactive printer installer is not supported.

### How do I remove software?

Use `omarchy-pkg-remove` (or `omarchy-pkg-drop <alias>`) for packages recorded
in the current user's pinned Nix profile. Core/declarative packages cannot be
removed from that profile; edit the NixOS/Home Manager host and switch a new
generation. The menu refreshes after profile changes, and same-session desktop
discovery works with `gtk-launch <desktop-id>`.

### Which web apps are included?

The core profile includes Linear and Slack web apps and excludes Basecamp and
HEY launchers. The profile and both graphical launch paths are verified;
physical target acceptance remains separate.

For errors, collect the commands in [Troubleshooting](45-troubleshooting.md)
and check the physical-test gaps in [Getting Started](02-getting-started.md).
