# Gaming

Gaming is outside the OmixOS Pi 4 v0.1 acceptance target. The Pi host
deliberately disables gaming and heavy optional applications; no Steam,
RetroArch, Battle.net, Lutris, Heroic, Moonlight, or cloud-gaming installer is
promised by the image. Physical GPU and performance behavior is unverified.

The workstation/M2 profiles also set gaming off by default. A future host may
enable a compatible Nixpkgs package set through an explicit profile, but the
upstream _Install > Gaming_ menu is not an Arch package installer on OmixOS.

Do not use the presence of upstream Quattro hotkeys or documentation as a
support claim. Record any future gaming enablement in the host profile and run
the ARM/physical acceptance checks before documenting it as available.
