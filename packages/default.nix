{ pkgs, omarchySrc }:

let
  runtime = pkgs.callPackage ./omarchy-runtime.nix {
    inherit omarchySrc;
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
}
