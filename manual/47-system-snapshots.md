# System generations and rollback

OmixOS does not create Limine/Snapper filesystem snapshots on update. NixOS
keeps generations of the declarative system closure, and `nixos-rebuild` can
switch between them without mutating the runtime store.

After a bad switch, select an earlier generation from the systemd-boot menu or
run:

```bash
sudo nixos-rebuild switch --rollback
```

This rolls back system packages, modules, services, and the configured desktop
profile. `omarchy update` creates these generations through its NixOS adapter;
it does not restore user files under `/home` or writable Home Manager state.
Keep personal files in backups/version control.

The Pi image uses the maintained Raspberry Pi boot chain; the VM and M2 hosts
use their declared EFI/systemd-boot paths. There is no supported `limine-scan`,
`omarchy-snapshot`, direct-boot toggle, or snapshot restoration flow in this
port.
