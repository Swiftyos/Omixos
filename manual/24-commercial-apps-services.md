# Commercial apps and services

The upstream Omarchy manual lists Arch/AUR installers for commercial desktop
applications. OmixOS does not ship those mutable installers. The Pi 4 core
profile stays ARM-safe and declarative; workstation or private overlays may add
an application only when a compatible Nix package exists.

## Web services

Linear and Slack are included as browser-backed web-app desktop entries. They
open through the packaged `omarchy-launch-webapp` wrapper and do not install a
proprietary native client. The app-library path is the same-session
`gtk-launch` path; both entries launched compositor-visible Chromium windows
in the graphical VM. This is not physical Pi acceptance evidence.

Basecamp and HEY launchers are intentionally removed from the OmixOS runtime.
The HEY mail handler, mailto association, and preinstalled HEY hotkeys are also
removed. Do not rely on the upstream 37signals integrations being present.

## Optional services

1Password, Bitwarden, Spotify, Dropbox, and similar optional apps can use the
pinned user-profile aliases or a private host/profile overlay. Tailscale and
Sunshine have NixOS service adapters, and SSH has a declarative authorized-key
adapter; enable/configure those services rather than copying Arch service
commands. NordVPN and ONCE remain explicit unavailable boundaries. Never paste
credentials or private keys into this repository.

The current Pi image has no embedded Wi-Fi credentials, SSH key, or reusable
password. NetworkManager handles networking; SSH access requires an explicit
authorized-key configuration and rebuild.
