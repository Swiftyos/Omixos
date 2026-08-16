# Branding

OmixOS keeps Quattro branding in the immutable runtime and allows writable
user overrides for the shell, screensaver, and About view. The upstream
Plymouth/SDDM boot-login branding commands are not part of this port: OmixOS
uses the target's declarative NixOS boot/login modules and does not mutate
`/usr/share` or `/etc` at runtime.

## Screensaver and About screen

Edit the writable files under:

```text
~/.config/omarchy/branding/screensaver.txt
~/.config/omarchy/branding/about.txt
```

The Quattro shell reloads these user assets. `omarchy transcode ascii` remains
available when the runtime includes its image helper:

```bash
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Physical boot splash and login branding are target-specific and unverified.
