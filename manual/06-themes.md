# Themes

Theme activation is one of the Quattro workflows retained by OmixOS. Built-in
themes live in the immutable runtime; user themes and generated state are
copied into writable Home Manager paths. Optional app retinting is
profile-dependent and is not evidence that every upstream application is
installed on the Pi.

Omarchy comes with twenty-two beautiful themes. You can select between them via _Style > Theme_ in the Omarchy Menu (`Super + Space`) or hop directly to the theme selector using `Super + Ctrl + Shift + Space`.

Each theme styles the desktop, terminal, neovim, activity screen (btop), Chromium, and the entire Omarchy shell: top bar, menu, notifications, OSD, and the lock screen. (For Obsidian, you must manually select the Omarchy theme via _Appearance > Themes_ inside the app).

Themes have a set of background images that you can pick between using `Super + Ctrl + Space`.

You can find even more themes on [the extra themes page](https://omarchy.org/themes/) or even [make your own theme](43-making-your-own-theme.md).

The built-in set includes Tokyo Night, Catppuccin, Lumon, Ethereal,
Everforest, Gruvbox, Miasma, Hackerman, Osaka Jade, Kanagawa, Nord, Matte
Black, Vantablack, Ristretto, Retro 82, Flexoki Light, Rose Pine, Catppuccin
Latte, and White. The live selector is the authoritative preview because it
renders the complete current shell and selected background.

The optional Aether integration is a pinned, verified ARM package at version
4.28.0. Add it to the current user's Nix profile with `omarchy-pkg-add aether`
and remove it with `omarchy-pkg-drop aether`; that real profile lifecycle is
covered by a graphical add/launch/remove test. The physical Pi test remains
pending.

### Unlocks

The upstream _Style > Unlock_ workflow targets its Arch boot-decryption
stack. OmixOS currently uses target-owned NixOS boot and greetd/PAM policy, so
that boot-unlock selector is not claimed as ported. Desktop lock styling still
follows the active shell theme; PAM authentication requires physical target
acceptance.
