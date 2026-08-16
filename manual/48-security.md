# Security

OmixOS's security model is declarative and target-specific. Do not infer the
upstream Omarchy Arch installer, encryption defaults, firewall, or package
mirror behavior from this manual.

## Accounts and passwords

The Pi image starts the `omix` graphical account locked and embeds no reusable
password. From a trusted local session, initialize it once:

```bash
sudo omixos-set-initial-password
```

The helper is the only narrowly scoped passwordless sudo rule and refuses to
run once the account is initialized. Normal sudo then requires that password.
The root account remains locked in the image. SSH public keys must be added
declaratively to a private host overlay; no private key is embedded.

The macOS VM has the same locked-account first-boot behavior. The Apple-silicon
live USB is an ephemeral recovery/installer environment with a separate
explicit live-session policy.

## Updates and rollback

Security updates arrive through pinned Nix flake inputs and a new NixOS
generation. Run `nix flake update` deliberately, validate with `nix flake
check`, and deploy with `nixos-rebuild`. `omarchy update` never runs Pacman,
Yay, AUR, or Arch migration commands. See [updates](30-updates.md).

## Physical and network scope

NetworkManager provides the Pi's DHCP/Wi-Fi path. SSH is not broadly enabled by
the image, and remote sudo remains password-protected. Pi/M2 physical boot,
firmware, peripherals, and performance remain acceptance gaps.
