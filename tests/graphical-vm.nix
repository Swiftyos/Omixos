{
  pkgs,
  testModules,
}:

pkgs.testers.runNixOSTest {
  name = "omixos-graphical-smoke";

  # The native ARM development VM does not provide nested KVM. AArch64 QEMU
  # still supplies its normal virtio GPU while the test runs under TCG.
  requiredFeatures.kvm = false;

  nodes.machine =
    { lib, ... }:
    {
      imports = testModules;

      networking.hostName = "omixos-graphical-test";
      omixos.omarchy = {
        profile = "core";
        greetd = {
          enable = true;
          autoLogin = true;
        };
      };

      services.openssh.enable = false;

      # The emulated virtio GPU has no host-side accelerated renderer in the
      # Docker builder. Exercise the real DRM/Wayland session with Mesa's
      # software renderer; physical VC4 remains a separate Pi acceptance gate.
      environment.sessionVariables = {
        AQ_NO_MODIFIERS = "1";
        LIBGL_ALWAYS_SOFTWARE = "1";
        # TCG needs longer than UWSM's 30-second default to observe the
        # compositor environment exported by Hyprland.
        UWSM_WAIT_VARNAMES_TIMEOUT = "120";
        WLR_RENDERER_ALLOW_SOFTWARE = "1";
      };

      virtualisation = {
        cores = 4;
        graphics = false;
        memorySize = 6144;
      };

      # The VM framework owns the ephemeral root disk and boot loader.
      boot.loader.systemd-boot.enable = lib.mkForce false;
    };

  testScript = ''
    import shlex

    def as_omix(command):
        environment = (
            "HOME=/home/omix USER=omix LOGNAME=omix "
            "XDG_RUNTIME_DIR=/run/user/1000 "
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        )
        session_environment = (
            "export HYPRLAND_INSTANCE_SIGNATURE="
            "\"$(find /run/user/1000/hypr -mindepth 1 -maxdepth 1 -type d "
            "-printf '%f\\n' 2>/dev/null | head -n1)\"; "
            "export WAYLAND_DISPLAY="
            "\"$(find /run/user/1000 -maxdepth 1 -type s "
            "-name 'wayland-[0-9]*' -printf '%f\\n' 2>/dev/null | head -n1)\"; "
        )
        return (
            "runuser -u omix -- env "
            + environment
            + " bash -lc "
            + shlex.quote(session_environment + command)
        )

    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("greetd.service")

    machine.wait_until_succeeds(
        as_omix("hyprctl monitors -j | jq -e 'length > 0'"),
        timeout=240,
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell shell ping | grep -Fx ok"),
        timeout=240,
    )

    machine.succeed(
        as_omix("hyprctl layers -j | grep -F 'omarchy-bar'")
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell notifications ping | grep -Fx ok"),
        timeout=60,
    )

    machine.succeed(
        as_omix("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    )
    machine.wait_until_succeeds(
        as_omix("hyprctl layers -j | grep -F 'omarchy-menu'"),
        timeout=30,
    )

    machine.succeed(as_omix("omarchy-theme-set Catppuccin"))
    machine.succeed(
        "grep -Fx catppuccin /home/omix/.local/state/omarchy/current/theme.name"
    )
    machine.succeed(
        "test -f \"$(readlink -f /home/omix/.local/state/omarchy/current/background)\""
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell shell ping | grep -Fx ok"),
        timeout=30,
    )

    # Exercise the actual Wayland clients and session services used by the
    # core profile. Start the terminal through xdg-terminal-exec so this also
    # proves Ghostty is the configured default, and launch Linear through the
    # same gtk-launch path used by the shell's application library.
    machine.succeed(
        as_omix(
            "systemd-run --user --collect --unit=omixos-test-terminal "
            "--property=Type=exec xdg-terminal-exec"
        )
    )
    machine.wait_until_succeeds(
        as_omix(
            "hyprctl clients -j | jq -e "
            "'any(.[]; ((.class // \"\") | ascii_downcase | contains(\"ghostty\")))'"
        ),
        timeout=60,
    )
    # Software-rendered GUI clients are CPU-intensive under AArch64 TCG. The
    # terminal has been accepted, so close it before starting Chromium.
    machine.succeed(as_omix("systemctl --user stop omixos-test-terminal.service"))
    machine.wait_until_succeeds(
        as_omix("hyprctl clients -j | jq -e 'length == 0'"),
        timeout=30,
    )

    # The AArch64 TCG VM has software rendering and no interactive keyring
    # unlock. Set the wrapper's explicit test mode on the gtk-launch process;
    # real desktop sessions do not receive these concessions.
    machine.succeed(
        as_omix(
            "env OMIXOS_GRAPHICAL_TEST=1 gtk-launch Linear.desktop"
        )
    )
    machine.wait_until_succeeds(
        as_omix("hyprctl clients -j | jq -e 'length > 0'"),
        timeout=180,
    )
    machine.succeed(as_omix("systemctl --user stop 'omarchy-webapp-*'"))
    machine.wait_until_succeeds(
        as_omix("hyprctl clients -j | jq -e 'length == 0'"),
        timeout=30,
    )

    machine.succeed(
        as_omix(
            "systemd-run --user --collect --unit=omixos-test-nautilus "
            "--property=Type=exec nautilus --new-window"
        )
    )
    machine.wait_until_succeeds(
        as_omix("hyprctl clients -j | jq -e 'length >= 1'"),
        timeout=120,
    )

    machine.succeed(
        as_omix(
            "systemd-run --user --pipe --wait --collect bash -lc "
            + shlex.quote(
                "wl-copy --foreground omixos-clipboard & "
                "copy_pid=$!; sleep 2; "
                "test \"$(wl-paste --no-newline)\" = omixos-clipboard; "
                "kill $copy_pid"
            )
        )
    )
    machine.succeed(
        as_omix(
            "systemd-run --user --pipe --wait --collect "
            "grim /tmp/omixos-graphical-smoke.png"
        )
    )
    machine.succeed(
        "file /tmp/omixos-graphical-smoke.png | grep -F 'PNG image data'"
    )

    machine.succeed(
        as_omix(
            "systemd-run --user --pipe --wait --collect "
            "notify-send --urgency=critical --expire-time=10000 "
            "'OmixOS graphical test' 'Notification delivery works'"
        )
    )
    machine.wait_until_succeeds(
        as_omix("hyprctl layers -j | grep -F 'omarchy-notifications'"),
        timeout=30,
    )
    machine.succeed(
        as_omix("systemd-run --user --pipe --wait --collect wpctl status")
    )

    machine.succeed(
        as_omix("command -v inotifywait && xkbcli list --load-exotic >/dev/null")
    )
    machine.succeed(
        as_omix("test -z \"$(systemctl --user --failed --no-legend)\"")
    )
  '';
}
