# Package matrix

This initial audit starts from `install/omarchy-base.packages` and
`install/omarchy-other.packages` in quattro. Availability/build status is only
marked verified after Nix evaluates or builds it on `aarch64-linux`.

| Omarchy package / function | Nixpkgs attribute or NixOS facility | Class | v0.1 role | ARM/build status |
| --- | --- | --- | --- | --- |
| `hyprland` | `pkgs.hyprland`, `programs.hyprland` | core portable | Required compositor | ARM closure passed; exact Lua config reports `config ok`; live test pending |
| `quickshell-git` | Nixpkgs derivation overridden to source `28771c7c74b42e20afca0b1b63980cb46515537c` | core, exact source pin | Required current shell | Native ARM build passed with all required modules; graphical API test pending |
| `uwsm` | `pkgs.uwsm`, Hyprland `withUWSM` | core portable | Session lifecycle | ARM closure passed; generated session entry inspected; live test pending |
| `xdg-desktop-portal-hyprland` | Hyprland portal module | core portable | Portals/screen sharing | ARM build passed; live sharing pending |
| `xdg-desktop-portal-gtk` | `pkgs.xdg-desktop-portal-gtk` | core portable | GTK portal fallback | ARM build passed; live picker pending |
| `foot` | `pkgs.foot` | core portable | Default terminal | ARM closure passed; launch pending |
| `chromium` | `pkgs.chromium` | core portable | Default browser | ARM evaluation passed; configured caches missed the locked build, so native source build was required |
| `nautilus` | `pkgs.nautilus` | core portable | File manager | ARM build passed; launch pending |
| `gum`, `wtype` | same-named Nixpkgs attributes | core portable | Writable plugin/theme prompts and text injection | ARM evaluation passed |
| `wl-clipboard` | `pkgs.wl-clipboard` | core portable | Clipboard/history | ARM closure passed; live test pending |
| `grim`, `slurp` | same-named attributes | core portable | Screenshots | ARM closure passed; live VC4 test pending |
| `hyprpicker` | `pkgs.hyprpicker` | core portable | Color picker/capture flows | ARM closure passed; live capture pending |
| `hyprsunset` | `pkgs.hyprsunset` | core portable | Night light | ARM closure passed; live control pending |
| `wireplumber`, `pamixer` | same-named attributes + PipeWire module | core portable | Audio/control | ARM closure passed; physical audio pending |
| `networkmanager` | NixOS NetworkManager module | core service | Ethernet/Wi-Fi | ARM closure passed; Pi physical pending |
| `bluez`, `bluez-utils` | `pkgs.bluez` + Bluetooth module | core service | Bluetooth | ARM closure passed; Pi physical pending |
| `brightnessctl` | `pkgs.brightnessctl` | core portable | Brightness | ARM closure passed; hardware path pending |
| `udiskie`, `gvfs-*` | `pkgs.udiskie`, GVfs/UDisks modules | core portable/service | Removable storage | ARM closure passed; device test pending |
| Noto fonts | `noto-fonts*` attributes | core portable | Shell/app glyphs | ARM font-cache build passed; live rendering pending |
| JetBrains Mono Nerd | `pkgs.nerd-fonts.jetbrains-mono` | core portable | Shell monospace glyphs | ARM font-cache build passed; live rendering pending |
| Omarchy icon font | `pkgs.omarchy-fonts`, sourced from upstream `default/fonts/omarchy/omarchy.ttf` | bundled asset | Branded glyphs | Packaged and registered; live rendering pending |
| `imv`, `imagemagick`, `qrencode` | same-named attributes | core portable | Images/QR/helpers | ARM closure passed; live helpers pending |
| `btop`, `eza`, `fd`, `fzf`, `tmux`, `nvim` | Nixpkgs | workstation | Developer profile | Generic ARM workstation closure passed |
| Docker stack | NixOS Docker module + packages | optional portable | Containers | Disabled on Pi by default |
| OBS/Kdenlive/GPU recorder | Nixpkgs/custom | deferred | Recording/editing | v0.1 non-goal; GPU recorder unresolved |
| LibreOffice/Xournal++ | Nixpkgs | optional heavy | Workstation | M2 configuration evaluation passed; build pending |
| Steam/Lutris/Battle.net | Nixpkgs/vendor | gaming/architecture-specific | None | Deferred; not Pi scope |
| Obsidian/Zoom/Discord/vendor apps | varies | proprietary/vendor | None | Deferred; many are x86-only |
| Pacman/Yay/ALPM hooks | none | Arch-specific | None | Intentionally not ported |
| Limine/mkinitcpio/Snapper integration | target NixOS boot/generations | Arch-specific replacement | Rollback | Replaced by target hardware modules/generations |
| Pi kernel/firmware/VC4/Bluetooth | `nixos-raspberrypi` modules | hardware-specific | Required Pi | BCM2711 kernel, firmware, U-Boot, and host closure build passed; image/physical test pending |
| Asahi kernel/firmware/GPU | `nixos-apple-silicon` module | hardware-specific | Secondary target | Locked module evaluation passed; physical test pending |

Optional packages use platform availability filtering; essential core packages
fail the configuration rather than disappearing silently. The custom runtime,
fonts, and exact Quickshell built locally; the configured caches supplied most
Nixpkgs dependencies but not the locked Chromium derivation during this run.
