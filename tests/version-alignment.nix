{
  lib,
  pkgs,
  nixpkgs,
  flakeLockFile,
  configurations,
  # Configurations composed on a deliberately different nixpkgs (the Asahi
  # stack keeps its own pin). They must still satisfy the quattro floor, but
  # are not required to match pkgs.hyprland exactly.
  auxConfigurations ? { },
}:

# Eval-time guards for the version relationships that once broke silently:
# the flake carried a nixos-26.05 branch URL whose tip froze Hyprland at
# 0.55.4 while the omarchy quattro Lua config needs the 0.56 monitor API, and
# nothing compared what the built systems resolve against what the port
# requires or what the lockfile records.
#
# 1. The primary nixpkgs lock entry must pin an exact rev, and that rev must
#    be the one this evaluation actually resolved. A branch URL that drifts
#    from the lock makes Nix re-resolve the tip and build something the lock
#    never recorded.
# 2. Every NixOS configuration must run the same Hyprland as pkgs.hyprland,
#    including image variants composed through foreign builders such as
#    nixos-raspberrypi's installer.
# 3. That Hyprland must satisfy the omarchy quattro floor: the Lua config
#    reads monitor.reserved (default/hypr/qconsole.lua), which Hyprland
#    introduced in 0.56.

let
  quattroHyprlandFloor = "0.56";

  lock = builtins.fromJSON (builtins.readFile flakeLockFile);
  rootNixpkgs = lock.nodes.${lock.root}.inputs.nixpkgs;
  primaryName = if builtins.isList rootNixpkgs then builtins.head rootNixpkgs else rootNixpkgs;
  primary = lock.nodes.${primaryName};

  lockedRev = primary.locked.rev or "";
  originalRev = primary.original.rev or "";
  resolvedRev = nixpkgs.rev or "";

  hyprlandVersionOf = _name: configuration: configuration.config.programs.hyprland.package.version;
  configVersions = lib.mapAttrs hyprlandVersionOf configurations;
  auxVersions = lib.mapAttrs hyprlandVersionOf auxConfigurations;

  misaligned = lib.filterAttrs (_name: version: version != pkgs.hyprland.version) configVersions;
  belowFloor = lib.filterAttrs (_name: version: !lib.versionAtLeast version quattroHyprlandFloor) (
    configVersions // auxVersions
  );

  renderedVersions = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: version: "  ${name}: hyprland ${version}") (configVersions // auxVersions)
  );

  checks = [
    {
      ok = originalRev != "";
      message = ''
        The primary nixpkgs input (${primaryName}) is locked from a branch
        reference, not an exact rev. Pin the rev in flake.nix so a fresh
        resolution can never silently build a different package set than the
        lockfile records.
      '';
    }
    {
      ok = resolvedRev == lockedRev;
      message = ''
        This evaluation resolved nixpkgs ${resolvedRev}, but flake.lock
        records ${lockedRev}. The flake.nix URL and the lockfile disagree;
        run `nix flake lock` and commit the result.
      '';
    }
    {
      ok = misaligned == { };
      message = ''
        These configurations resolve a different Hyprland than pkgs.hyprland
        (${pkgs.hyprland.version}), so the flake checks would test a compositor
        the images do not ship:
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: version: "  ${name}: ${version}") misaligned
        )}
      '';
    }
    {
      ok = belowFloor == { };
      message = ''
        These configurations run a Hyprland older than ${quattroHyprlandFloor}.
        The pinned omarchy quattro Lua config reads monitor.reserved
        (default/hypr/qconsole.lua), which such a Hyprland does not expose;
        every monitor event would raise "attempt to index a nil value" in the
        session's red error bar:
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: version: "  ${name}: ${version}") belowFloor
        )}
      '';
    }
  ];

  failures = builtins.filter (check: !check.ok) checks;
in
assert lib.assertMsg (failures == [ ]) (
  lib.concatStringsSep "\n\n" (map (check: check.message) failures)
);
pkgs.runCommand "omixos-version-alignment"
  {
    passthru.hyprlandVersion = pkgs.hyprland.version;
  }
  ''
    cat > "$out" <<'EOF'
    nixpkgs: ${lockedRev}
    ${renderedVersions}
    EOF
  ''
