# Making your own theme

You can add your own themes to `~/.config/omarchy/themes`. Copy one of the
immutable runtime themes from `$OMARCHY_PATH/share/omarchy/themes` as a base,
then edit the writable copy. As long as it is inside that folder, it is
included in the theme selection menu.

The main file you have to tweak is `colors.toml`. That defines the color set
used to generate configurations for the intended Ghostty terminal, Chromium,
Hyprland, Neovim, and the Omarchy shell (top bar, menu, notifications, OSD,
and lock screen). Optional applications are profile-dependent.

You can also use the included Aether application to create a new theme using a lovely GUI interface to play with colors and search for backgrounds. Just start it via the apps menu on `Super + Alt + Space`.

### Light mode

If you're making a light mode theme, set `mode = "light"` at the top of your `colors.toml`. Then it'll automatically be paired with light mode for all the apps. (The old way of dropping an empty file called `light.mode` in the root of your theme still works too.)

### Icon colors

If you'd like to color-match the file manager icons to your theme, add a file called `icons.theme` with the name of the icon set you want to use. By default, the options are: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Unlock image

Themes supplied with `unlock.png` and `preview-unlock.png` images will be listed under _Style > Unlock_. Your `unlock.png` should preferably be a transparent png. And you can create the preview image using `omarchy plymouth preview`.

### Theming apps Omarchy doesn't cover

If you use an app that isn't in that list, you can teach Omarchy to theme it yourself with a template. Drop a file in `~/.config/omarchy/themed/` named after the config it generates plus a `.tpl` extension, and write the config with `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` through `{{ color15 }}`, and the rest of the palette as placeholders. Every time you switch themes, the file is regenerated with that theme's colors.

There's a fully commented `alacritty.toml.tpl.sample` in that folder to copy from — it lists every variable you can use, plus the `_strip` and `_rgb` modifiers for apps that want their colors without the `#` or as decimal RGB. Your templates take priority over Omarchy's own, so you can also use this to override how a built-in app gets themed.

### Distributing your theme

If you want to distribute your theme, put it on a public git server and have
users copy it into their writable `~/.config/omarchy/themes` directory (or add
it through a private declarative overlay). The upstream _Install > Style >
Theme_ URL installer is not a supported Arch package operation on OmixOS.

Theme switching and writable overlays are exercised in the graphical ARM VM;
physical Pi/M2 rendering remains an acceptance gap.
