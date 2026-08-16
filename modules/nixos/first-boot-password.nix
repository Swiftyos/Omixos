{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.omixos.firstBootPassword;
  user = config.omixos.omarchy.user;

  setInitialPassword = pkgs.writeShellScriptBin "omixos-set-initial-password" ''
    set -euo pipefail

    password_field="$(${pkgs.gawk}/bin/awk -F: '$1 == "${user}" { print $2; exit }' /etc/shadow)"
    case "$password_field" in
      "!" | "!!" | "") ;;
      *)
        echo "The ${user} password is already initialized; use passwd normally." >&2
        exit 1
        ;;
    esac

    exec ${pkgs.shadow}/bin/passwd ${lib.escapeShellArg user}
  '';
in
{
  options.omixos.firstBootPassword.enable = lib.mkEnableOption ''
    a one-time, passwordless helper that initializes the locked OmixOS user
  '';

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ setInitialPassword ];

    # The image starts a deliberately locked graphical user, so ordinary sudo
    # cannot initialize its first password. Permit only this self-disabling
    # helper; after the shadow entry changes, the helper refuses to run again.
    security.sudo.extraRules = [
      {
        users = [ user ];
        commands = [
          {
            command = "${setInitialPassword}/bin/omixos-set-initial-password";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
