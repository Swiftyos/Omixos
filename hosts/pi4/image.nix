{
  lib,
  pkgs,
  ...
}:

let
  setInitialPassword = pkgs.writeShellScriptBin "omixos-set-initial-password" ''
    set -euo pipefail

    password_field="$(${pkgs.gawk}/bin/awk -F: '$1 == "omix" { print $2; exit }' /etc/shadow)"
    case "$password_field" in
      "!" | "!!" | "") ;;
      *)
        echo "The omix password is already initialized; use passwd normally." >&2
        exit 1
        ;;
    esac

    exec ${pkgs.shadow}/bin/passwd omix
  '';
in
{
  # The portal validator integration tests start bubblewrap from inside the
  # Nix build sandbox. Nested/user namespaces are unavailable in common Docker
  # builders (including the native ARM verification builder), so those two
  # tests fail before exercising portal code. Keep the production validator
  # enabled and only skip the package's build-time test phase for this image.
  nixpkgs.overlays = [
    (_final: prev: {
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (_old: {
        doCheck = false;
      });
    })
  ];

  image.baseName = lib.mkForce "omixos-pi4";

  # No password or SSH private material is embedded in the image. The local
  # graphical session auto-starts; set a password from a trusted console before
  # relying on screen unlock or sudo, and add an SSH public key declaratively.
  users.users.root.initialHashedPassword = lib.mkForce "!";

  # The image auto-starts a deliberately locked user, so normal sudo cannot
  # initialize its first password. Permit exactly this self-disabling helper:
  # it runs only while the shadow field is still locked and cannot reset an
  # initialized password. No reusable password or broader NOPASSWD rule ships.
  environment.systemPackages = [ setInitialPassword ];
  security.sudo.extraRules = [
    {
      users = [ "omix" ];
      commands = [
        {
          command = "${setInitialPassword}/bin/omixos-set-initial-password";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
