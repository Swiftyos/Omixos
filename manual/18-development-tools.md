# Development Tools

OmixOS separates the ARM-safe core from the optional workstation profile. The
menu can describe upstream Omarchy integrations, but it is not a Pacman/AUR
installer on this port. Add system software through Nixpkgs or a private flake
overlay, then rebuild the target generation. Pi 4 physical performance and
optional application support remain unverified.

## Alternative Editors

OmixOS ships with [Neovim](https://neovim.io/) in the core profile. If you'd
like another editor, declare it in a host/profile overlay and rebuild. The
upstream _Install > Package_ and _Install > AUR_ paths are unsupported here.

Theme matching is offered for `VSCode`, `Cursor`, `VSCodium`, and `Helix`.

You can set the system-wide default editor under `Setup > Defaults > Editor`.

## Environment

The workstation profile provides a conservative set of development tools. Add
language runtimes and frameworks declaratively; the upstream _Install >
Development_ and mise-bootstrap flows are not guaranteed on OmixOS.

The majority of these environments are managed by [Mise](https://mise.jdx.dev/). It's a tool that lets you install and run multiple versions of a programming language on the same machine. It's like rbenv or rvm for Ruby or virtualenv for Python, but it works for a bunch of different environments.

For a project-local runtime, use the project's own environment or add a Nix
development shell. `mise` is not part of the supported system-update path.

## Docker

[Docker](https://www.docker.com/) is available only in profiles that enable the
declarative container feature (not the Pi 4 core image). It is managed by
NixOS, with Docker Compose and Lazydocker where the selected profile includes
them.

Remember to checkout the Lazydocker command to manage your containers in a cool TUI using `Super + Shift + D`.

Configure databases through your NixOS/container project rather than the
upstream menu installer.

## GitHub CLI

[The GitHub CLI](https://cli.github.com/) can be added declaratively to a
workstation profile. It is not a lazy-loading mise stub on the Pi image.

You can also perform a bunch of other GitHub operations using this command. Just run `gh` to see everything that's possible.

There's a lazy-installing stub for `ghui` for managing your pull requests in a TUI too. And [lazygit](https://github.com/jesseduffield/lazygit) is preinstalled, if you'd like to drive git itself from a TUI as well.
