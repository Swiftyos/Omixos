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
- Their mutating command entry points fail safely or report the NixOS
  generation workflow.
- Greetd is used for the initial lightweight login path; SDDM theme parity is
  deferred.
- `omarchy update` documents flake updates and rebuilds instead of mutating the
  checkout automatically.

## Application gaps

- Ghostty is the verified default, Foot remains a fallback, Neovim and
  `gtk-launch` are in `core`, and Linear launches as an isolated Chromium app
  through the GTK desktop-entry path. Slack's desktop entry is verified.
  Physical Pi app performance remains unmeasured.
- Basecamp is excluded. HEY's desktop entry, handler, preinstalled hotkeys, and
  mailto association are removed; ordinary `mailto:` handling falls back to
  Chromium.

- Heavy media, gaming, Windows VM, commercial, and x86-only applications are
  outside Pi v0.1.
- `omarchy-pkg-present/missing` is a best-effort command check for menu guards,
  not a Nix package database API.
- Live Chromium chrome retinting is deferred: the upstream helper writes a
  managed policy under mutable `/etc`, while OmixOS keeps system policy
  declarative. Theme state, shell colors, applications, and backgrounds still
  use the writable runtime theme path.
- The Pi host deliberately reuses the pinned generic ARM Chromium derivation.
  Letting the hardware flake's board-specific FFmpeg override propagate into
  Chromium produced an unrelated 57k-action rebuild and exceeded the native
  builder's memory; Pi browser video acceleration remains a physical test.
- The Omarchy icon font is packaged and registered; live glyph rendering still
  belongs to graphical acceptance testing.

## Security/first boot

- No password or SSH key is embedded. The auto-started local user must run the
  image's narrowly authorized, locked-account-only password initializer from a
  trusted console before PAM unlock and general sudo are usable.
- Wi-Fi credentials belong to NetworkManager state or a private deployment
  secret, never this repository.
