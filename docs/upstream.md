# Upstream Omarchy baseline

Inspected on **2026-08-16**.

| Field | Value |
| --- | --- |
| Repository | `/Users/swifty/dev/omarchy` |
| Fetch/push remote | `git@github.com:basecamp/omarchy.git` |
| Branch | `quattro` |
| Upstream tracking ref | `origin/quattro` |
| Commit | `30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec` |
| Commit date | `2026-08-16T04:51:30-07:00` |
| Commit subject | `Update tokyo-night winding-road background (#7057)` |
| Ahead/behind | `+0 / -0` |
| Dirty status | Clean |
| First OmixOS commit targeting it | `40367f0ed0c66bdb4f334eed506d025b29f41665` |

The flake's `omarchy-src` input pins this exact commit. A sibling path is used
only with an explicit development `--override-input`.

Finder later created untracked `.DS_Store` files in the checkout. Its tracked
tree, branch, and commit remain unchanged; OmixOS never edits that source tree.

## Source inspected

- `AGENTS.md`
- `docs/file-layout.md`
- `docs/omarchy-shell.md`
- `docs/theming.md`
- `docs/testing.md`
- `docs/update-process.md`
- `install/omarchy-base.packages`
- `install/omarchy-other.packages`
- `shell/`, including its QML imports and plugin registry
- `bin/`, including runtime, theme, launcher, package, update, and system commands
- `config/hypr/` and `default/hypr/`
- `config/omarchy/shell.json`
- `default/omarchy/omarchy-menu.jsonc`
- `themes/`, `default/themed/`, `applications/`, and `default/systemd/`

## Findings that constrain the port

- Quattro is a single long-running Quickshell desktop. The bar, menu,
  notifications, lock UI, panels, and services are plugins in that process.
- Hyprland configuration is Lua and loads immutable defaults through
  `$OMARCHY_PATH`, then writable user modules and generated theme state.
- Current generated theme state belongs in
  `~/.local/state/omarchy/current/`; user plugins and overrides belong under
  `~/.config/omarchy/`.
- Upstream installs `quickshell-git`, so runtime API compatibility—not merely
  the package name—must be verified in the graphical ARM test. The official
  `omarchy-pkgs` recipe for this baseline pins Quickshell commit
  `28771c7c74b42e20afca0b1b63980cb46515537c`
  (`0.3.0.r20.g28771c7`); OmixOS pins the same source.
- The Arch update/package/install/migration stack is not portable and must be
  replaced by NixOS generations or made explicitly unavailable.

The upstream clone is treated as read-only and remained clean after discovery.
