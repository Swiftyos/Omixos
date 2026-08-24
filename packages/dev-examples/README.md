# OmixOS development environments

Ready-made Nix development environments. Each directory is a small flake:
`cd` into it and run `nix develop` to enter a shell with the toolchain on
PATH, isolated from the rest of the system. Leave with `exit`; nothing is
installed globally.

These are yours to edit. OmixOS seeded them once on first login and will
never overwrite your changes; delete any directory you do not want. Every
flake pins the same nixpkgs revision as the OmixOS system, so entering a
shell reuses packages the system already has instead of downloading a second
copy.

| Directory     | What you get                                            |
| ------------- | ------------------------------------------------------- |
| `n8n/`        | Node.js + pnpm for running and extending n8n            |
| `llama-cpp/`  | C/C++ toolchain for building and hacking on llama.cpp   |
| `pytorch-uv/` | Python + uv, preconfigured for PyTorch wheels on NixOS  |

## Everyday use

```console
cd ~/dev/n8n
nix develop        # enter the environment
node --version     # tools are now on PATH
exit               # leave it again
```

The first `nix develop` in each directory downloads its toolchain and writes
a `flake.lock`; afterwards entry is instant and offline. Each directory's
README covers the environment-specific workflow.

## Making your own

Copy any of these directories, rename it, and adjust the `packages` list in
its `flake.nix` — search packages at <https://search.nixos.org/packages>.
The pattern in these examples (one `devShells.default` per flake) scales
from a single tool to a full polyglot toolchain.

If you use direnv, `echo 'use flake' > .envrc && direnv allow` inside a
directory makes the environment load automatically whenever you enter it.
