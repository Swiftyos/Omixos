# Development Tools

OmixOS separates the ARM-safe core from the optional workstation profile. The
menu can describe upstream Omarchy integrations, but package operations use the
OmixOS-pinned Nixpkgs user profile rather than Pacman/AUR. Search and install
with `omarchy-pkg-install <term>`; remove user-installed entries with
`omarchy-pkg-remove`/`omarchy-pkg-drop`. Core/system software belongs in a host
or private flake overlay and a new generation. Pi 4 physical performance and
hardware-specific acceptance remain unverified; the generic AArch64 graphical
package lifecycle has passed.

## Alternative Editors

OmixOS ships with [Neovim](https://neovim.io/) in the core profile. If you'd
like another editor, declare it in a host/profile overlay and rebuild. The
upstream _Install > Package_ and _Install > AUR_ labels do not describe the
implementation here: supported ARM packages use the Nix profile, while
explicit x86 or unavailable packages return a reason.

Theme matching is offered for `VSCode`, `Cursor`, `VSCodium`, and `Helix`.

You can set the system-wide default editor under `Setup > Defaults > Editor`.

## Environment

The workstation profile provides a conservative set of development tools. Add
language runtimes and frameworks declaratively; the upstream _Install >
Development_ and mise-bootstrap flows are not guaranteed on OmixOS.

The majority of these environments are managed by [Mise](https://mise.jdx.dev/). It's a tool that lets you install and run multiple versions of a programming language on the same machine. It's like rbenv or rvm for Ruby or virtualenv for Python, but it works for a bunch of different environments. OmixOS provides NixOS adapters for the development-environment install/remove commands; they manage Mise state without pretending to be Arch package transactions.

For a project-local runtime, use the project's own environment or add a Nix
development shell. `mise` is not part of the supported system-update path.

## Docker

[Docker](https://www.docker.com/) is enabled declaratively in the Pi 4 image as
part of the normal Quattro development workflow. NixOS manages the daemon and
ships Docker Compose and Lazydocker with that profile.

Remember to checkout the Lazydocker command to manage your containers in a cool TUI using `Super + Shift + D`.

Configure databases through your NixOS/container project rather than the
upstream menu installer.

## GitHub CLI

[The GitHub CLI](https://cli.github.com/) can be added declaratively to a
workstation profile. It is not a lazy-loading mise stub on the Pi image.

You can also perform a bunch of other GitHub operations using this command. Just run `gh` to see everything that's possible.

There's a lazy-installing stub for `ghui` for managing your pull requests in a TUI too. And [lazygit](https://github.com/jesseduffield/lazygit) is preinstalled, if you'd like to drive git itself from a TUI as well.
