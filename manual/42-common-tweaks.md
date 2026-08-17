# Common tweaks

This is a collection of common user-state tailorings to the OmixOS setup.
Defaults in the Nix store are immutable; Home Manager seeds a destination only
when it does not already exist, so ordinary rebuilds do not overwrite your
changes. Keep a backup of important user configuration regardless.

If you screw something up, restore the affected file from your backup or remove
it and reactivate Home Manager. The upstream _Update > Config_ and
`omarchy-reinstall` operations are Arch-only and are not available on OmixOS;
use Home Manager activation or a NixOS generation switch for declarative
changes.

### Reveal all tray icons all the time

By default, tray icons, like Dropbox, 1password, or Steam, are hidden behind the tray expander arrow, which reveals them when you hover it. If you'd like to have them exposed all the time, right-click the expander arrow to open the tray icon manager, then pin the icons you want to keep visible (you can also hide the ones you never want to see).

### Rounded window corners

Omarchy's default design is one of square corners, but if you like to soften that up a bit, you can change `~/.config/hypr/looknfeel.lua` so rounding is no longer commented out:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Remove window gaps

On laptop displays, some people prefer not to waste any pixels on window gaps (or even a top bar, which you can toggle off with `Super + Shift + Space`). You can toggle all gaps and borders off with `Super + Shift + Backspace`, or remove them permanently by removing the comments in this section of `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
