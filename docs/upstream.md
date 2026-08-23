# Upstream Omarchy baseline

Re-pinned on **2026-08-23** (first baseline `30f7a060` inspected 2026-08-16).

| Field | Value |
| --- | --- |
| Repository | `/Users/swifty/dev/omarchy` |
| Fetch/push remote | `git@github.com:basecamp/omarchy.git` |
| Branch | `quattro` |
| Upstream tracking ref | `origin/quattro` |
| Commit | `f4f3d4c71a0a5c392b20ce05291531881a1b3bfe` |
| Commit date | `2026-08-23T20:02:02+02:00` |
| Commit subject | `Add plan for finishing Sunshine/Moonlight into a remote desktop` |
| Ahead/behind | `+0 / -0` |
| Worktree status | Tracked tree clean; untracked `.DS_Store` metadata present |
| First OmixOS commit targeting it | `40367f0ed0c66bdb4f334eed506d025b29f41665` (baseline `30f7a060`) |

The 2026-08-23 re-pin absorbed the 39 upstream commits between `30f7a060`
and `f4f3d4c7`: the theme-staging and yt-dlp title security fixes, UTF-16
clipboard decoding and the larger history, webp theme backgrounds plus the
`qt6-imageformats` requirement, the Quake console scratchpad, the packaged
Quickshell 0.3.1 floor, the OWE Wi-Fi fix, Remove > AI, T3 Code, the
Antigravity/Ori agent switch, and the About logo animation with its
`fastfetch` layout under `/etc/fastfetch`.

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

The upstream clone is treated as read-only and its tracked tree remained
unchanged after discovery.
