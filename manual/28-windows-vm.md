# Windows VM

The upstream Omarchy Windows VM workflow is not implemented in OmixOS. The
port's supported VM is a native AArch64 NixOS development/installation VM on
Apple Silicon, not a Windows guest. Heavy virtualization, gaming, and Windows
integration are deferred and are not part of the Pi 4 acceptance target.
Battle.net and other Windows-only paths therefore return an explicit
unsupported-target message rather than attempting to install a VM.

See [Getting Started](02-getting-started.md) and the
[OmixOS installation manual](../docs/install.md) for the macOS-hosted VM
commands. Do not run the upstream `omarchy windows-vm` or mutable package
installer instructions on this NixOS port.
