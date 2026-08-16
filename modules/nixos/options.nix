{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
in
{
  options.omixos.omarchy = {
    enable = lib.mkEnableOption "the Omarchy quattro desktop on NixOS";

    package = mkOption {
      type = types.package;
      default = pkgs.omarchy-runtime;
      defaultText = lib.literalExpression "pkgs.omarchy-runtime";
      description = "Packaged immutable Omarchy runtime.";
    };

    shellPackage = mkOption {
      type = types.package;
      default = pkgs.omarchy-shell;
      defaultText = lib.literalExpression "pkgs.omarchy-shell";
      description = "Omarchy Quickshell desktop package.";
    };

    user = mkOption {
      type = types.str;
      default = "omix";
      description = "Local user that starts the graphical Omarchy session.";
    };

    profile = mkOption {
      type = types.enum [
        "core"
        "workstation"
      ];
      default = "core";
      description = "Application profile; Pi 4 should use core.";
    };

    greetd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the lightweight greetd login path.";
      };

      autoLogin = mkOption {
        type = types.bool;
        default = true;
        description = "Start the Omarchy session for the configured user automatically.";
      };
    };

    features = {
      containers = lib.mkEnableOption "container development tools";
      recording = lib.mkEnableOption "screen-recording tools";
      gaming = lib.mkEnableOption "gaming tools";
      heavyApplications = lib.mkEnableOption "large workstation applications";
      printing = lib.mkEnableOption "CUPS printing support";
    };
  };

  config.assertions = lib.mkIf config.omixos.omarchy.enable [
    {
      assertion = pkgs.stdenv.hostPlatform.isLinux;
      message = "OmixOS's Omarchy desktop requires Linux.";
    }
    {
      assertion = config.users.users ? ${config.omixos.omarchy.user};
      message = "omixos.omarchy.user must name a declared NixOS user.";
    }
  ];
}
