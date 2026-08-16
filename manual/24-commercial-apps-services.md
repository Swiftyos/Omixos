# Commercial apps and services

The upstream Omarchy manual lists Arch/AUR installers for commercial desktop
applications. OmixOS does not ship those mutable installers. The Pi 4 core
profile stays ARM-safe and declarative; workstation or private overlays may add
an application only when a compatible Nix package exists.

## Web services

Linear and Slack are included as browser-backed web-app desktop entries. They
open through the packaged `omarchy-launch-webapp` wrapper and do not install a
proprietary native client. The generic ARM graphical test launches Linear
through the same `gtk-launch` path used by the application library.

Basecamp and HEY launchers are intentionally removed from the OmixOS runtime.
The HEY mail handler, mailto association, and preinstalled HEY hotkeys are also
removed. Do not rely on the upstream 37signals integrations being present.

## Optional services

1Password, Bitwarden, Spotify, Dropbox, Tailscale, ONCE, NordVPN, and similar
services are not guaranteed by the base image. If a service has a compatible
Nix package, add it in a private host/profile overlay and configure it using
that package's normal NixOS options. Never paste credentials or private keys
into this repository.

The current Pi image has no embedded Wi-Fi credentials, SSH key, or reusable
password. NetworkManager handles networking; SSH access requires an explicit
authorized-key configuration and rebuild.
