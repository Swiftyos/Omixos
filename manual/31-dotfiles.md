# Dotfiles

OmixOS is primarily configured through user state in `~/.config` and
`~/.local/state`. The immutable runtime is under the Nix store at
`$OMARCHY_PATH/share/omarchy`; do not edit it. Home Manager seeds defaults only
when a destination is absent, so user changes survive rebuilds. If a system
default needs changing, use a NixOS/Home Manager option or a writable override.

The key configs can be edited straight from the Omarchy menu (`Super + Space`), like _Setup > Monitors_, _Setup > Keybindings_, _Setup > Input_, and _Setup > Config > [file]_. When you do it this way, any process that needs restarting after config edits automatically will be after you quit the editor (Neovim by default — `:wq`, remember! — but you can change that via _Setup > Defaults > Editor_).

Here's a list of the key files in `~/.config` and what they control:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | The main Hyprland config. Loads the Omarchy defaults plus your override files below. [Learn more about Hyprland configs](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Your own keybindings and overrides of the defaults. |
| `~/.config/hypr/monitors.lua` | Controls your monitors, resolution, and position. |
| `~/.config/hypr/input.lua` | Controls your keyboard layout, mouse, and trackpad settings. |
| `~/.config/hypr/looknfeel.lua` | Controls gaps, borders, animations, and the rest of the look. |
| `~/.config/hypr/autostart.lua` | Controls extra processes started with the session. |
| `~/.config/omarchy/shell.json` | Controls the Omarchy shell: bar position, layout, and widgets, plus screensaver, lock, and idle timings. |
| `~/.config/ghostty/config` | Controls the intended default Ghostty terminal. |
| `~/.XCompose` | Defines your quick-access emoji and name/email autocomplete. Make sure to run `omarchy-restart-xcompose` after making changes. |

If you end up making a lot of changes to tweak your own setup, it's a good idea to backup all these dotfiles. [Stow is a great way to do that](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starting your own apps with the session

If you want something to run every time you log in — a sync daemon, a chat app, your own script — put it in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

That starts the command as part of the session, so it's properly cleaned up when you log out again.

### Running scripts on system events

Omarchy fires hooks at a handful of moments, and you can hang your own scripts off them. They live in `~/.config/omarchy/hooks/<event>.d/`, one directory per event, and every executable file in there runs when the event happens:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Right after the desktop has started |
| `post-update` | During `omarchy update`, after packages and migrations |
| `pre-refresh-pacman` | Upstream hook name; not invoked by OmixOS Nix rebuilds |
| `theme-set` | After a theme change (theme name in `$1`) |
| `font-set` | After a font change (font name in `$1`) |
| `battery-low` | When the battery gets low (percentage in `$1`) |

Hooks that the packaged Quattro runtime supports remain user operations, but
there is no Arch package/update hook transaction. Add system-level behavior as
declarative NixOS services; keep user hooks under writable Omarchy state.

### Adding your own menu entries

The Omarchy menu (`Super + Space`) can be extended with your own rows by editing `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entries are keyed by a dotted id, and the id is what places them in the tree, so `personal` shows up on the root menu and `personal.notes` shows up inside it:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reuse an existing id and you override that row instead of adding a new one. The file ships with all the available fields documented as comments.

### Adding your own shell exports, functions, and aliases

Omarchy ships with a bunch of ergonomic aliases and helpful functions, but it's very common to want to add your own. You should add both aliases, functions, and exports in `~/.bashrc`. This file will not be overwritten on updates. If you want to change any of the Omarchy defaults, you can also safely add them here.

### Changing internal Omarchy files

Look, this is your computer. You can do whatever you want with it, but do not
edit `$OMARCHY_PATH/share/omarchy` directly: it is an immutable Nix store
output, not a writable system package path. Override defaults in `~/.config/*`
or with a NixOS/Home Manager option instead.

You can change just about everything that way, like the default keybindings.
Just edit `~/.config/hypr/bindings.lua` to replace an app. Add the replacement
through NixOS/Home Manager first; `omarchy-pkg-add joplin-bin` is an unsupported
Arch command on this port:

```
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

If you need to change the runtime itself, patch or override the pinned source in
the OmixOS flake. Do not switch an Arch dev channel or edit a mutable `~/omarchy`
checkout as a deployment mechanism.

### Resetting any changes

If you end up making a mess of user configuration, restore the file from your
backup or remove it and run the Home Manager activation again. There is no
destructive Arch `omarchy reinstall configs` operation in this port.
