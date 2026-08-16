{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = "omixos-apple-usb";

  image.baseName = lib.mkForce "omixos-apple-silicon-usb";
  isoImage.volumeID = lib.mkForce "OMIXOS_USB";

  # Carry the exact source used for the image so the live environment is also
  # a recovery and installation environment. The symlink is immutable; copy it
  # to a writable directory before adding machine-specific vendorfw.
  environment.etc."omixos".source = inputs.self;
  environment.systemPackages = with pkgs; [
    dosfstools
    e2fsprogs
    gptfdisk
    parted
  ];

  # This is an ephemeral live system with a locked root account. greetd starts
  # the local desktop directly, and the live omix session may use sudo without
  # a password for installation/recovery work. SSH remains disabled.
  users.users = {
    root.initialHashedPassword = lib.mkForce "!";
    omix.initialHashedPassword = lib.mkForce "";
  };
  security.sudo.wheelNeedsPassword = lib.mkForce false;
  services.openssh.enable = lib.mkForce false;

  omixos.omarchy = {
    profile = "workstation";
    greetd.autoLogin = true;
    features = {
      containers = false;
      gaming = false;
      heavyApplications = true;
      printing = false;
      recording = false;
    };
  };

  # The upstream Apple-silicon installer extracts this Mac's legally
  # non-redistributable peripheral firmware from the internal Asahi ESP during
  # every live boot. It intentionally cannot be embedded in this image.
  assertions = [
    {
      assertion = config.hardware.asahi.enable;
      message = "The OmixOS Apple-silicon USB must include Asahi hardware support.";
    }
  ];
}
