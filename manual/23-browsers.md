# Browsers

OmixOS ships Chromium as the declarative default browser on ARM64. It is
opened by `Super + Shift + Return`, by the XDG web handlers, and by the Linear
and Slack web-app launchers in the current profile.

The upstream _Install > Browser_ menu is not a Pacman/AUR installer here. Add
another browser through a NixOS/profile overlay, then rebuild. Physical Pi
browser acceleration and optional browser parity remain unverified.

## Making one the default

The current Home Manager module declares Chromium as the default for HTML and
HTTP(S). A host overlay can change the XDG MIME defaults declaratively. The
compatibility command is useful for inspecting the current state, but it does
not install a browser:

```bash
omarchy default browser
```

## Chromium integrations

The Quattro runtime includes its Chromium-compatible URL-copy and download
helpers where the required browser integration is available. These workflows
depend on the graphical session and are covered by the ARM VM smoke tests; the
physical Pi acceptance list still includes browser launch and media behavior.

## Web apps

Linear and Slack are packaged as web-app desktop entries in the shipped OmixOS
profile. Basecamp and HEY launchers are intentionally absent. See
[Web Apps](25-web-apps.md) for the profile and its verification status.
