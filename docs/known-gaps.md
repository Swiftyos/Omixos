# Known gaps

## Blocking support claims

- The locked flake, package checks, headless and graphical AArch64 VMs, generic
  host closure, Pi host closure, and compressed Pi image build on native ARM64.
- The exact quattro-pinned Quickshell builds with Networking, Bluetooth, PAM,
  Polkit, PipeWire, UPower, Hyprland, and Wayland session-lock modules enabled.
  Shell IPC, bar, menu, notifications, theme switching, application launch,
  clipboard, screenshot, and PipeWire control pass in the graphical ARM VM;
  PAM lock authentication and hardware-backed modules remain physical tests.
- Hyprland 0.55.4 reports `config ok` for the exact seeded Lua configuration;
  compositor startup and software-rendered Wayland clients pass in the
  graphical ARM VM. VC4 rendering still requires the physical Pi.
- The image-only desktop portal derivation skips two upstream integration tests
  that require unavailable user namespaces in the native ARM Docker builder.
  Portal validation remains enabled and D-Bus activation passes in the system
  VM; live file-picker and screen-sharing workflows remain unverified.
- The verified compressed Pi image must still boot on a physical Pi 4.
- Pi VC4, HDMI, audio, Ethernet, Wi-Fi, Bluetooth, input, reboot, shutdown,
  remote deploy, rollback, and performance remain untested.
- The generic macOS/HVF VM has passed a clean NixOS install, disk-only reboot,
  final-generation reboot, and full graphical acceptance. This does not test
  Apple hardware.
- The Apple-silicon USB ISO passes integrity/structure checks and reaches its
  graphical AArch64 EFI boot menu under EDK2/QEMU. Physical external-USB boot,
  Apple drivers, and the required internal Asahi UEFI environment remain
  untested.
- The M2 host evaluates by design but remains physically untested.
- The evaluable M2 host does not embed Apple's non-redistributable peripheral
  firmware; a real host overlay must provide it and enable extraction.
- Forgejo currently has no registered Actions runner. The complete native ARM
  check surface exists, but no workflow is bound to an invented runner label.

## Intentional NixOS differences

- Pacman, Yay, AUR, ALPM hooks, Arch migrations, channels, ISO installer,
  Limine scripts, and mutable `/etc` provisioning are not ported.
- Package discovery/install/removal uses the pinned Nixpkgs revision and each
  user's Nix profile; system changes use NixOS generations. The 31 commands
  with no faithful Pi/NixOS behavior fail with an explicit boundary reason.
- Greetd is used for the initial lightweight login path; SDDM theme parity is
  deferred.
- `omarchy update` documents flake updates and rebuilds instead of mutating the
  checkout automatically.

## Raspberry Pi operational notes

- The first `omarchy pkg install` search fetches and evaluates the pinned
  Nixpkgs revision; on a 4 GB Pi this takes minutes and several GB of RAM
  before the evaluation cache warms, and package search requires the network.
- `omarchy update` inherits upstream's 10 GiB free-space requirement, which is
  tight on small SD cards; a USB 3 SSD root is recommended for sustained use.
- `omarchy-hw-autoscale` reconciles GDK_SCALE at session start only; plugging
  a different display into a running session keeps the previous integer scale
  until the next login (Hyprland's own monitor scale still follows hotplug).

## Application gaps

- Ghostty is the verified default, Foot remains a fallback, and Neovim and
  `gtk-launch` are in `core`. Linear and Slack both launch as isolated
  Chromium apps through the GTK desktop-entry path. Physical Pi app
  performance remains unmeasured.
- Basecamp is excluded. HEY's desktop entry, handler, preinstalled hotkeys, and
  mailto association are removed; ordinary `mailto:` handling falls back to
  Chromium.
- The live user-package test searches pinned Nixpkgs, installs XTerm, discovers
  and launches its desktop entry in the same session, then removes it through
  the app-library ownership path. Declarative system packages still require a
  rebuild rather than mutable removal.
- Aether 4.28.0 is packaged from its verified upstream ARM64 release and its
  add/launch/remove lifecycle passes. Omawrite, Omacalc, and Omacut also build
  and launch natively on ARM64.
- VoxType 0.7.4 starts with its offline base.en model, GTK4 OSD, bar status,
  Hyprland bindings, and enable/disable lifecycle in the graphical VM. Real
  microphone capture and typing remain a physical Pi acceptance item.
- Heavy media and x86-only gaming/Windows applications remain outside the Pi
  target. Their command paths return architecture-specific explanations where
  no AArch64 implementation exists. Of the quattro Install > AI catalog,
  Ollama installs and runs natively (CPU inference); ChatGPT and Grok are
  provided as web applications; LM Studio, T3 Code, and Minecraft return
  curated no-ARM64 explanations. Cliamp has no Nixpkgs build yet and is
  explained as unsupported rather than failing raw.
- The Antigravity (`agy`), `hey`, and `ori` agent CLIs are not preinstalled as
  mise stubs the way the Arch installer provisions them; mise ships in the
  core profile and `omarchy-mise-install` provisions each tool on first use.
- Live Chromium chrome retinting is deferred: the upstream helper writes a
  managed policy under mutable `/etc`, while OmixOS keeps system policy
  declarative. Theme state, shell colors, applications, and backgrounds still
  use the writable runtime theme path.
- The Pi host deliberately reuses the verified generic ARM application
  derivations for Chromium, Ghostty, the Omarchy runtime/shell, Aether, and the
  native Qt apps. Letting the hardware flake's board-specific FFmpeg override
  propagate into hardware-independent applications produced unrelated large
  rebuilds; Pi browser video acceleration remains a physical test.
- The Omarchy icon font is packaged and registered; live glyph rendering still
  belongs to graphical acceptance testing.

## Security/first boot

- No password or SSH key is embedded. The auto-started local user must run the
  image's narrowly authorized, locked-account-only password initializer from a
  trusted console before PAM unlock and general sudo are usable.
- Wi-Fi credentials belong to NetworkManager state or a private deployment
  secret, never this repository.
