# Gaming

Gaming is outside the OmixOS Pi 4 v0.1 acceptance target. Steam, Heroic,
Lutris, and Battle.net return explicit unavailable messages on Pi ARM because
their required x86/Windows runtimes are absent; the Windows VM is likewise not
implemented. Moonlight/RetroArch are optional profile packages, not evidence
of a working Pi gaming stack. Physical GPU and performance behavior is
unverified.

The workstation/M2 profiles also set gaming off by default. A future host may
enable a compatible Nixpkgs package set through an explicit profile, but the
upstream _Install > Gaming_ menu is not an Arch package installer on OmixOS.

The catalog retains the commands so the menu can explain the boundary; it does
not silently install a package. Record any future gaming enablement in the
host profile and run the ARM/physical acceptance checks before documenting it
as available.
