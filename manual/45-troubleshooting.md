# Troubleshooting

First identify whether a problem is in the declarative system, the graphical
ARM VM, or untested physical hardware. Do not use the upstream Arch snapshot
or reinstall commands.

## A bad generation

Select an earlier NixOS generation at boot or run:

```bash
sudo nixos-rebuild switch --rollback
```

The command changes the active generation; it does not restore `/home`.

## Diagnostics

```bash
systemctl --failed
systemctl --user --failed
hyprctl version
hyprctl monitors
wpctl status
nmcli device
```

The ARM graphical smoke test covers the greetd/UWSM/Hyprland/Quickshell path,
core app launch, clipboard, screenshots, notifications, theme switching, and
PipeWire. Pi VC4/HDMI, audio, networking, Bluetooth, input, remote deploy,
and M2/Asahi behavior still require physical acceptance.

For password initialization on a fresh Pi image, use the one-time
`sudo omixos-set-initial-password` helper. It refuses to run after the account
has a password; there is no reusable default password.

For a runtime/CLI issue, run `omarchy commands --check` and the relevant
`omarchy <route> --help`. Arch-only commands should report the NixOS boundary,
not mutate the host.
