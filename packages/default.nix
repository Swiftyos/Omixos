{
  pkgs,
  aetherPackage,
  omarchySrc,
  nixpkgsRef,
  omawrite-src,
  omacut-src,
  omacalc-src,
}:

let
  omawrite = pkgs.callPackage ./omarchy-qt-app.nix {
    pname = "omawrite";
    version = "0.5.0";
    src = omawrite-src;
  };
  omacut = pkgs.callPackage ./omarchy-qt-app.nix {
    pname = "omacut";
    version = "0.4.0";
    src = omacut-src;
    withMultimedia = true;
  };
  omacalc = pkgs.callPackage ./omarchy-qt-app.nix {
    pname = "omacalc";
    version = "0-unstable-2026-08-04";
    src = omacalc-src;
  };
  runtime = pkgs.callPackage ./omarchy-runtime.nix {
    inherit nixpkgsRef omarchySrc;
    inherit aetherPackage;
    omacalcPackage = omacalc;
    omacutPackage = omacut;
    omawritePackage = omawrite;
  };
  shell = pkgs.callPackage ./omarchy-shell.nix {
    omarchy-runtime = runtime;
  };
  fonts = pkgs.callPackage ./omarchy-fonts.nix {
    omarchy-runtime = runtime;
  };
in
{
  omarchy-runtime = runtime;
  omarchy-shell = shell;
  omarchy-fonts = fonts;
  inherit
    omawrite
    omacut
    omacalc
    ;
  aether = aetherPackage;
}
