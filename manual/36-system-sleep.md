# System sleep

OmixOS declares the sleep-lock user service for the graphical session, but
suspend, hibernation, and wake behavior are hardware dependent. Do not claim
that hibernation is enabled by default: the Pi 4 image has no supported
hibernation recipe, and physical suspend/resume remains untested on Pi and M2.

Power profiles are provided by the NixOS service where the hardware exposes
them. Inspect the current state with:

```bash
systemctl status power-profiles-daemon
```

Use `omarchy toggle suspend` only as a shell compatibility command; it does
not create a swap subvolume or mutate a Limine installation. Configure swap,
resume, and hibernation declaratively for a specific host if that hardware is
validated.
