{
  lib,
  pkgs,
  ...
}:

let
  portal = pkgs.xdg-desktop-portal.overrideAttrs (_old: {
    doCheck = false;
  });
  portalGtk = pkgs.xdg-desktop-portal-gtk.override {
    xdg-desktop-portal = portal;
  };
  portalPackages = [
    portal
    portalGtk
    pkgs.xdg-desktop-portal-hyprland
  ];

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
  # enabled and only skip this package instance's build-time test phase. Do
  # not replace it through an overlay: that would unnecessarily rebuild every
  # package whose dependency graph mentions the portal, including Chromium.
  xdg.portal.enable = lib.mkForce false;
  services.dbus.packages = portalPackages;
  systemd.packages = portalPackages;
  environment = {
    systemPackages = portalPackages ++ [ setInitialPassword ];
    pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
    sessionVariables = {
      NIXOS_XDG_OPEN_USE_PORTAL = "1";
      NIX_XDG_DESKTOP_PORTAL_DIR = "/run/current-system/sw/share/xdg-desktop-portal/portals";
    };
    etc."xdg/xdg-desktop-portal/portals.conf".text = ''
      [preferred]
      default=hyprland;gtk;
    '';
  };

  image.baseName = lib.mkForce "omixos-pi4";

  # No password or SSH private material is embedded in the image. The local
  # graphical session auto-starts; set a password from a trusted console before
  # relying on screen unlock or sudo, and add an SSH public key declaratively.
  users.users.root.initialHashedPassword = lib.mkForce "!";
  security.sudo.wheelNeedsPassword = lib.mkForce true;

  # The image auto-starts a deliberately locked user, so normal sudo cannot
  # initialize its first password. Permit exactly this self-disabling helper:
  # it runs only while the shadow field is still locked and cannot reset an
  # initialized password. No reusable password or broader NOPASSWD rule ships.
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
