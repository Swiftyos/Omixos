{
  pkgs,
  testModules,
}:

pkgs.testers.runNixOSTest {
  name = "omixos-system-smoke";

  nodes.machine =
    { lib, ... }:
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
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    machine.succeed("systemctl is-active NetworkManager.service")
    machine.succeed("systemctl is-active dbus.service")
    machine.succeed("systemctl is-active polkit.service")
    machine.succeed("systemctl is-active upower.service")

    machine.succeed("test -x /run/current-system/sw/bin/Hyprland")
    machine.succeed("test -x /run/current-system/sw/bin/quickshell")
    machine.succeed("test -x /run/current-system/sw/bin/omarchy-version")
    machine.succeed("test -x /run/current-system/sw/bin/foot")
    machine.succeed("test -x /run/current-system/sw/bin/chromium")
    machine.succeed("test -x /run/current-system/sw/bin/nautilus")

    machine.succeed("test -f /home/omix/.config/hypr/hyprland.lua")
    machine.succeed("test -f /home/omix/.config/uwsm/env.d/10-omarchy")
    machine.succeed("grep -Fx foot.desktop /home/omix/.config/xdg-terminals.list")
    machine.succeed("grep -F 'chromium-browser.desktop' /home/omix/.config/mimeapps.list")
    machine.succeed("test -f /home/omix/.local/state/omarchy/current/theme.name")
    machine.succeed("grep -Fx tokyo-night /home/omix/.local/state/omarchy/current/theme.name")

    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'omarchy-version | grep -F quattro-nixos'")
    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'omarchy-default-browser | grep -Fx chromium'")
    machine.succeed("su - omix -s /run/current-system/sw/bin/bash -c 'omarchy-pkg-add >/tmp/blocked.out 2>&1; test $? -eq 2'")
    machine.succeed("grep -F 'disabled on OmixOS' /tmp/blocked.out")

    machine.succeed("test -L /home/omix/.config/systemd/user/graphical-session.target.wants/omarchy-crash-watch.service")
    machine.succeed("test -L /home/omix/.config/systemd/user/graphical-session.target.wants/omarchy-sleep-lock.service")
  '';
}
