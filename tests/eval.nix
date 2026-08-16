{ lib, ... }:

{
  assertions = [
    {
      assertion = lib.versionAtLeast lib.version "26.05";
      message = "OmixOS currently targets NixOS 26.05 or newer.";
    }
  ];
}
