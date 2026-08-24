{
  pkgs,
  testModules,
}:

let
  testNixpkgs = pkgs.writeTextDir "share/omixos-test-nixpkgs/flake.nix" ''
    {
      outputs = { self }: let
        pkgs = import ${pkgs.path} { system = "aarch64-linux"; };
      in {
        packages.aarch64-linux.hello = pkgs.hello;
      };
    }
  '';
in
pkgs.testers.runNixOSTest {
  name = "omixos-system-smoke";

  # The ARM development VM and common Docker builders have no nested KVM.
  # QEMU's aarch64 machine falls back to TCG, so keep the NixOS-test feature
  # gate while allowing this smoke boot to run without /dev/kvm.
  requiredFeatures.kvm = false;

  nodes.machine =
    { lib, pkgs, ... }:
    {
      imports = testModules;

      networking.hostName = "omixos-test";
      omixos.omarchy = {
        profile = "core";
        greetd.enable = false;
      };

      services.openssh.enable = false;

      virtualisation = {
        cores = 4;
        graphics = false;
        memorySize = 4096;
      };

      # The VM framework owns the ephemeral root disk and boot loader.
      boot.loader.systemd-boot.enable = lib.mkForce false;

      # Offline local flake used to prove a real user-profile install without
      # relying on network access from the NixOS test VM.
      environment.systemPackages = [ testNixpkgs ];
      system.extraDependencies = [ pkgs.hello ];
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("systemctl is-active NetworkManager.service")
    machine.succeed("systemctl is-active dbus.service")
    machine.succeed("busctl call org.freedesktop.PolicyKit1 /org/freedesktop/PolicyKit1/Authority org.freedesktop.DBus.Peer Ping")
    machine.wait_for_unit("polkit.service")
    machine.succeed("busctl call org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.DBus.Peer Ping")
    machine.wait_for_unit("upower.service")

    machine.succeed("test -x /run/current-system/sw/bin/Hyprland")
    machine.succeed("test -x /run/current-system/sw/bin/quickshell")
    machine.succeed("test -x /run/current-system/sw/bin/omarchy-version")
    machine.succeed("test -x /run/current-system/sw/bin/ghostty")
    machine.succeed("test -x /run/current-system/sw/bin/foot")
    machine.succeed("test -x /run/current-system/sw/bin/gtk-launch")
    machine.succeed("test -x /run/current-system/sw/bin/nvim")
    machine.succeed("test -x /run/current-system/sw/bin/chromium")
    machine.succeed("test -x /run/current-system/sw/bin/nautilus")
    machine.succeed("test -x /run/current-system/sw/bin/omawrite")
    machine.succeed("test -x /run/current-system/sw/bin/omacut")
    machine.succeed("test -x /run/current-system/sw/bin/omacalc")
    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'command -v voxtype'")

    machine.succeed("test -f /home/omix/.config/hypr/hyprland.lua")
    machine.succeed("test -f /home/omix/.config/uwsm/env.d/10-omarchy")
    machine.succeed("grep -Fx com.mitchellh.ghostty.desktop /home/omix/.config/xdg-terminals.list")
    machine.succeed("grep -F 'chromium-browser.desktop' /home/omix/.config/mimeapps.list")
    machine.succeed("grep -F 'x-scheme-handler/mailto=chromium-browser.desktop' /home/omix/.config/mimeapps.list")
    machine.succeed("test -f /home/omix/.local/share/applications/Linear.desktop")
    machine.succeed("test -f /home/omix/.local/share/applications/Slack.desktop")
    machine.succeed("test ! -e /home/omix/.local/share/applications/Basecamp.desktop")
    machine.succeed("test ! -e /home/omix/.local/share/applications/HEY.desktop")
    machine.succeed("test -f /home/omix/.local/state/omarchy/migrations/application-profile-v1")
    machine.succeed("test -f /home/omix/.local/state/omarchy/migrations/default-terminal-ghostty-v1")
    machine.succeed("test -f /home/omix/.local/state/omarchy/current/theme.name")
    machine.succeed("grep -Fx tokyo-night /home/omix/.local/state/omarchy/current/theme.name")
    machine.succeed("test -f /home/omix/.config/voxtype/config.toml")
    machine.succeed("grep -Fx 'model = \"base.en\"' /home/omix/.config/voxtype/config.toml")
    machine.succeed("test -L /home/omix/.local/share/voxtype/models/ggml-base.en.bin")
    machine.succeed("test -s /home/omix/.local/share/voxtype/models/ggml-base.en.bin")

    machine.succeed("test -f /home/omix/dev/README.md")
    for example in ["n8n", "llama-cpp", "pytorch-uv"]:
        machine.succeed(f"test -f /home/omix/dev/{example}/flake.nix")
        machine.succeed(f"test -f /home/omix/dev/{example}/README.md")
        # The flakes must be valid Nix and carry the substituted system pin.
        machine.succeed(f"nix-instantiate --parse /home/omix/dev/{example}/flake.nix > /dev/null")
    machine.fail("grep -rF '@nixpkgsRef@' /home/omix/dev")
    machine.succeed("grep -F 'github:NixOS/nixpkgs/' /home/omix/dev/n8n/flake.nix")

    # Recreate the exact legacy launchers/default and prove the one-time
    # profile migration updates only those known OmixOS-seeded files.
    machine.succeed("printf 'foot.desktop\\n' > /home/omix/.config/xdg-terminals.list")
    machine.succeed("printf '[Desktop Entry]\\nExec=omarchy-launch-webapp https://launchpad.37signals.com\\n' > /home/omix/.local/share/applications/Basecamp.desktop")
    machine.succeed("printf '[Desktop Entry]\\nExec=omarchy-webapp-handler-hey %%u\\n' > /home/omix/.local/share/applications/HEY.desktop")
    machine.succeed("rm -f /home/omix/.local/state/omarchy/migrations/application-profile-v1 /home/omix/.local/state/omarchy/migrations/default-terminal-ghostty-v1")
    machine.succeed("systemctl restart home-manager-omix.service")
    machine.succeed("grep -Fx com.mitchellh.ghostty.desktop /home/omix/.config/xdg-terminals.list")
    machine.succeed("test ! -e /home/omix/.local/share/applications/Basecamp.desktop")
    machine.succeed("test ! -e /home/omix/.local/share/applications/HEY.desktop")

    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'omarchy-version | grep -F quattro-nixos'")
    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'omarchy-default-browser | grep -Fx chromium'")
    machine.succeed(
        "su - omix -s /run/current-system/sw/bin/bash -c "
        "'OMIXOS_NIXPKGS_REF=path:${testNixpkgs}/share/omixos-test-nixpkgs "
        "OMIXOS_NIX_PROFILE=/home/omix/.local/state/omixos-test-profile "
        "omarchy-pkg-add hello'"
    )
    machine.succeed("/home/omix/.local/state/omixos-test-profile/bin/hello | grep -F 'Hello, world!'")
    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'omarchy-pkg-present hello'")
    machine.succeed(
        "su - omix -s /run/current-system/sw/bin/bash -c "
        "'OMIXOS_NIX_PROFILE=/home/omix/.local/state/omixos-test-profile "
        "omarchy-pkg-drop hello'"
    )
    machine.succeed("test ! -e /home/omix/.local/state/omixos-test-profile/bin/hello")

    machine.succeed("test -L /home/omix/.config/systemd/user/graphical-session.target.wants/omarchy-crash-watch.service")
    machine.succeed("test -L /home/omix/.config/systemd/user/graphical-session.target.wants/omarchy-sleep-lock.service")
    machine.succeed("test -L /home/omix/.config/systemd/user/graphical-session.target.wants/voxtype.service")
  '';
}
