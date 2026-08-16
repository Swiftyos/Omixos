# Networking

OmixOS uses NetworkManager. Ethernet uses DHCP by default, and Wi-Fi can be
configured from the shell panel or NetworkManager tools:

```bash
nmcli device
nmtui
```

The Pi image contains no Wi-Fi credentials. Store connection state on the
target or configure it through a private deployment overlay; never commit
secrets here.

## Bluetooth and physical validation

The Pi host imports the maintained Raspberry Pi 4 Bluetooth module. Use
`bluetoothctl show` and the shell panel to inspect it. Wi-Fi, Bluetooth,
Ethernet, input, and audio still require physical Pi acceptance; the graphical
ARM VM is not evidence of board support.

## SSH deployment

SSH is not an open, passwordless default on the image. Add an authorized public
key declaratively under `users.users.omix.openssh.authorizedKeys.keys` in a
private host overlay, rebuild, and then deploy with `nixos-rebuild --target-host`.
Remote sudo remains password-protected.

## Tailscale and firewall

Tailscale, custom DNS helpers, Wi-Fi QR flows, and broad firewall policy are
not guaranteed by the Pi core profile. Add them as explicit NixOS services or
packages when needed. Do not rely on upstream menu entries as proof that a
service is installed.
