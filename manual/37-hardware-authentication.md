# Hardware authentication

The OmixOS core configures the normal user/password and shell lock path. It
does not promise fingerprint or FIDO2 hardware integration. PAM, physical
sensors, and authentication behavior remain acceptance tests on the real Pi or
M2 target.

If a target has a supported fingerprint/FIDO2 stack, add the appropriate NixOS
module and validate it on that host. Do not use the upstream _Setup > Security_
installers, which would try to mutate an Arch system.

On a newly flashed Pi image, the `omix` account is intentionally locked. Run
the one-time helper from a trusted local session before relying on password
unlock or general sudo:

```bash
sudo omixos-set-initial-password
```
