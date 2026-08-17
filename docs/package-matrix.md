# Package matrix

This audit starts from `install/omarchy-base.packages` and
`install/omarchy-other.packages` in quattro. Availability/build status is only
marked verified after Nix evaluates or builds it on `aarch64-linux`.

| Omarchy package / function | Nixpkgs attribute or NixOS facility | Class | v0.1 role | ARM/build status |
| --- | --- | --- | --- | --- |
| `hyprland` | `pkgs.hyprland`, `programs.hyprland` | core portable | Required compositor | ARM closure and exact Lua parse pass; compositor and mapped Wayland clients pass graphically |
| `quickshell-git` | Nixpkgs derivation overridden to source `28771c7c74b42e20afca0b1b63980cb46515537c` | core, exact source pin | Required current shell | Native ARM build plus shell IPC, bar, menu, and notifications pass graphically |
| `uwsm` | `pkgs.uwsm`, Hyprland `withUWSM` | core portable | Session lifecycle | Production greetd/UWSM/Hyprland launch path passes in ARM VM |
| `xdg-desktop-portal-hyprland` | Hyprland portal module | core portable | Portals/screen sharing | ARM build passed; live sharing pending |
| `xdg-desktop-portal-gtk` | `pkgs.xdg-desktop-portal-gtk` | core portable | GTK portal fallback | ARM build passed; live picker pending |
| `ghostty` | `pkgs.ghostty` | core portable | Default terminal | Ghostty 1.3.1 ARM build and mapped Wayland window pass through `xdg-terminal-exec` |
| `foot` | `pkgs.foot` | core portable | Fallback terminal and upstream desktop-entry compatibility | ARM closure passed |
| `gtk3` / `gtk-launch` | `pkgs.gtk3` | core portable | Application-library launcher | Installed in ARM system; Linear, Slack, Aether, the native Qt utilities, and a dynamically installed XTerm launch through `gtk-launch` |
| `chromium` | pinned generic `pkgs.chromium` | core portable | Default browser | Native ARM build and mapped window pass; Pi reuses the generic ARM derivation instead of the hardware flake's unrelated FFmpeg override |
| `nautilus` | `pkgs.nautilus` | core portable | File manager | ARM build and mapped Wayland window pass |
| Linear and Slack | project desktop entries + `omarchy-launch-webapp` | core web apps | Requested collaboration apps | Both open as isolated Chromium apps through `gtk-launch` in the graphical ARM VM |
| Basecamp and HEY | omitted | excluded | Explicitly not installed | Desktop entries absent; HEY handler, hotkeys, and mailto association removed |
| VoxType 0.7.4 + GTK4 OSD + base.en model | pinned flake input/overlay and Home Manager user service | core adapted | Offline push-to-talk dictation | Native ARM build; daemon, model, OSD, status, bindings, and remove/reinstall lifecycle pass graphically; physical microphone pending |
| Aether 4.28.0 | verified upstream ARM64 `.deb`, repackaged by `packages/aether.nix`; WebKitGTK 2.52.5 from exact cached NixOS 26.05 pin | installable native app | Graphical app store | Native ARM build and live user-profile add/launch/remove lifecycle pass |
| Omawrite, Omacalc, Omacut | pinned source inputs + native Qt derivations | core portable | Quattro writing, calculator, and cutting utilities | All three build and launch as compositor-visible ARM64 windows |
| Dynamic Nixpkgs applications | pinned Nixpkgs search + user Nix profile | user-installable | Omarchy package/app-library workflow | XTerm search/install, same-session desktop discovery, launch, and removal pass graphically |
| `gum`, `wtype` | same-named Nixpkgs attributes | core portable | Writable plugin/theme prompts and text injection | ARM evaluation passed |
| `wl-clipboard` | `pkgs.wl-clipboard` | core portable | Clipboard/history | Live Wayland copy/paste round trip passes |
| `grim`, `slurp` | same-named attributes | core portable | Screenshots | Live PNG capture passes in VM; physical VC4 path pending |
| `hyprpicker` | `pkgs.hyprpicker` | core portable | Color picker/capture flows | ARM closure passed; live capture pending |
| `hyprsunset` | `pkgs.hyprsunset` | core portable | Night light | ARM closure passed; live control pending |
| `wireplumber`, `pamixer` | same-named attributes + PipeWire module | core portable | Audio/control | Live `wpctl` session path passes; physical audio pending |
| `networkmanager` | NixOS NetworkManager module | core service | Ethernet/Wi-Fi | ARM closure passed; Pi physical pending |
| `bluez`, `bluez-utils` | `pkgs.bluez` + Bluetooth module | core service | Bluetooth | ARM closure passed; Pi physical pending |
| `brightnessctl` | `pkgs.brightnessctl` | core portable | Brightness | ARM closure passed; hardware path pending |
| `udiskie`, `gvfs-*` | `pkgs.udiskie`, GVfs/UDisks modules | core portable/service | Removable storage | ARM closure passed; device test pending |
| Noto fonts | `noto-fonts*` attributes | core portable | Shell/app glyphs | ARM font-cache build passed; live rendering pending |
| JetBrains Mono Nerd | `pkgs.nerd-fonts.jetbrains-mono` | core portable | Shell monospace glyphs | ARM font-cache build passed; live rendering pending |
| Omarchy icon font | `pkgs.omarchy-fonts`, sourced from upstream `default/fonts/omarchy/omarchy.ttf` | bundled asset | Branded glyphs | Packaged and registered; live rendering pending |
| `imv`, `imagemagick`, `qrencode` | same-named attributes | core portable | Images/QR/helpers | ARM closure passed; live helpers pending |
| `nvim` | `pkgs.neovim` | core portable | Default editor | Installed executable and editor configuration verified in ARM system test |
| `btop`, `eza`, `fd`, `fzf`, `tmux` | Nixpkgs | workstation | Developer profile | Generic ARM workstation closure passed |
| Docker stack | NixOS Docker module + packages | portable service | Containers | Enabled declaratively on Pi 4 with Compose and Lazydocker |
| OBS/Kdenlive/GPU recorder | Nixpkgs/custom | deferred | Recording/editing | v0.1 non-goal; GPU recorder unresolved |
| LibreOffice/Xournal++ | Nixpkgs | optional heavy | Workstation | M2 configuration evaluation passed; build pending |
| Steam/Lutris/Battle.net | Nixpkgs/vendor | gaming/architecture-specific | None | Deferred; not Pi scope |
| Obsidian/Zoom/Discord/vendor apps | varies | proprietary/vendor | None | Deferred; many are x86-only |
| Pacman/Yay/ALPM hooks | none | Arch-specific | None | Intentionally not ported |
| Limine/mkinitcpio/Snapper integration | target NixOS boot/generations | Arch-specific replacement | Rollback | Replaced by target hardware modules/generations |
| Pi kernel/firmware/VC4/Bluetooth | `nixos-raspberrypi` modules | hardware-specific | Required Pi | BCM2711 kernel, firmware, U-Boot, host closure, and compressed image build passed; verified generic ARM application derivations avoid board-media overlays for hardware-independent apps; physical test pending |
| Asahi kernel/firmware/GPU | `nixos-apple-silicon` module | hardware-specific | Secondary target | Locked module evaluation passed; physical test pending |

Optional packages use platform availability filtering; essential core packages
fail the configuration rather than disappearing silently. The custom runtime,
fonts, and exact Quickshell built locally. Aether uses an exact NixOS 26.05
package pin with a cached AArch64 WebKitGTK 2.52.5 artifact; Pi hardware policy
does not leak board-specific media overrides into hardware-independent apps.
