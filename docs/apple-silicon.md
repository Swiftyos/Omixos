# Apple Silicon M2

The M2 is secondary and imports the maintained
`nixos-apple-silicon` module while using the same OmixOS NixOS/Home Manager
desktop modules as Pi and the development VM.

Use the maintained Apple Silicon NixOS/Asahi UEFI installation process first,
including its current backup, partitioning, firmware, and recovery guidance.
This repository does not resize APFS, alter Apple recovery partitions, invoke
the Asahi installer, or build a custom destructive installer.

After that prerequisite, apply `.#m2`. The current host assumes the root
filesystem label `nixos`; the real machine must provide its generated
hardware/filesystem details. It deliberately disables peripheral-firmware
extraction for pure evaluation. A real deployment must add a flake-contained
copy of the installer-provided `vendorfw/firmware.cpio`, set
`hardware.asahi.peripheralFirmwareDirectory` to that directory, and set
`hardware.asahi.extractPeripheralFirmware = true`.

No historical Asahi workaround is enabled preemptively. Internal display,
GPU acceleration, keyboard, trackpad, Wi-Fi, Bluetooth, audio, brightness,
suspend/resume, and the workstation profile require physical M2 acceptance
before support is claimed.
