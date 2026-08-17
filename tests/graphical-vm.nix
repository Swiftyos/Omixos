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
        packages.aarch64-linux.xterm = pkgs.xterm;
      };
    }
  '';
in
pkgs.testers.runNixOSTest {
  name = "omixos-graphical-smoke";

  # The native ARM development VM does not provide nested KVM. AArch64 QEMU
  # still supplies its normal virtio GPU while the test runs under TCG.
  requiredFeatures.kvm = false;

  nodes.machine =
    { lib, pkgs, ... }:
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

      environment.systemPackages = [ testNixpkgs ];
      system.extraDependencies = [ pkgs.xterm ];
    };

  testScript = ''
    import shlex

    def as_omix(command):
        environment = (
            "HOME=/home/omix USER=omix LOGNAME=omix "
            "XDG_RUNTIME_DIR=/run/user/1000 "
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
            "PATH=/home/omix/.nix-profile/bin:/etc/profiles/per-user/omix/bin:/run/current-system/sw/bin "
            "XDG_DATA_DIRS=/home/omix/.nix-profile/share:/etc/profiles/per-user/omix/share:/run/current-system/sw/share"
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
        as_omix("timeout 10s hyprctl monitors -j | jq -e 'length > 0'"),
        timeout=240,
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell shell ping | grep -Fx ok"),
        timeout=240,
    )
    # The acceptance run is intentionally long under AArch64 TCG. Exercise
    # the real stay-awake control and keep the test from locking halfway
    # through application lifecycle checks.
    machine.succeed(
        as_omix("omarchy-toggle-idle stay-awake | grep -Fx disabled")
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell idle status | jq -e '.enabled == false and .stayAwake == true'"),
        timeout=30,
    )

    machine.succeed(
        as_omix("timeout 10s hyprctl layers -j | grep -F 'omarchy-bar'")
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell notifications ping | grep -Fx ok"),
        timeout=60,
    )

    # VoxType ships with the exact Quattro config and an offline Whisper
    # model. Its daemon, bar status, compositor bindings, and remove/install
    # lifecycle must all agree.
    machine.wait_until_succeeds(
        as_omix("systemctl --user is-active voxtype.service"),
        timeout=60,
    )
    machine.succeed(as_omix("voxtype --version | grep -F 'voxtype 0.7.4'"))
    machine.succeed(
        as_omix("voxtype status --format json | jq -e '.class == \"idle\"'")
    )
    machine.succeed(as_omix("command -v voxtype-osd-gtk4"))
    machine.succeed(as_omix("command -v voxtype-osd"))
    machine.wait_until_succeeds(
        as_omix("pgrep -u 1000 -f '[v]oxtype-osd-gtk4'"),
        timeout=30,
    )
    machine.fail(
        "journalctl --user -u voxtype.service --no-pager | "
        "grep -F 'Failed to spawn `voxtype-osd`'"
    )
    machine.succeed("grep -Fx 'model = \"base.en\"' /home/omix/.config/voxtype/config.toml")
    machine.succeed("test -s /home/omix/.local/share/voxtype/models/ggml-base.en.bin")
    machine.succeed(
        as_omix("timeout 10s hyprctl binds -j | jq -e 'any(.[]; .description == \"Start dictation (push-to-talk)\")'")
    )
    machine.succeed(
        as_omix("timeout 10s hyprctl binds -j | jq -e 'any(.[]; .description == \"Stop dictation (push-to-talk)\")'")
    )
    machine.succeed(
        as_omix("timeout 10s hyprctl binds -j | jq -e 'any(.[]; .description == \"Toggle dictation\")'")
    )

    machine.succeed(
        as_omix("OMIXOS_VOXTYPE_REMOVE_CONFIRM=1 omarchy-voxtype-remove")
    )
    machine.fail(as_omix("systemctl --user is-active voxtype.service"))
    machine.wait_until_succeeds(
        as_omix("omarchy-shell shell ping | grep -Fx ok"),
        timeout=30,
    )
    machine.fail(as_omix("omarchy-pkg-present voxtype-bin"))
    machine.fail(
        as_omix("timeout 10s hyprctl binds -j | jq -e 'any(.[]; .description == \"Start dictation (push-to-talk)\")'")
    )
    machine.succeed(as_omix("omarchy-voxtype-install"))
    machine.wait_until_succeeds(
        as_omix("systemctl --user is-active voxtype.service"),
        timeout=60,
    )
    machine.wait_until_succeeds(
        as_omix("omarchy-shell shell ping | grep -Fx ok"),
        timeout=30,
    )
    machine.succeed(as_omix("omarchy-pkg-present voxtype-bin"))
    machine.wait_until_succeeds(
        as_omix("timeout 10s hyprctl binds -j | jq -e 'any(.[]; .description == \"Start dictation (push-to-talk)\")'"),
        timeout=30,
    )

    machine.succeed(
        as_omix("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    )
    machine.wait_until_succeeds(
        as_omix("timeout 10s hyprctl layers -j | grep -F 'omarchy-menu'"),
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
            "timeout 10s hyprctl clients -j | jq -e "
            "'any(.[]; ((.class // \"\") | ascii_downcase | contains(\"ghostty\")))'"
        ),
        timeout=60,
    )
    # Software-rendered GUI clients are CPU-intensive under AArch64 TCG. The
    # terminal has been accepted, so close it before starting Chromium.
    machine.succeed(as_omix("systemctl --user stop omixos-test-terminal.service"))
    machine.wait_until_succeeds(
        as_omix("timeout 10s hyprctl clients -j | jq -e 'length == 0'"),
        timeout=30,
    )

    # Aether is not in Nixpkgs on ARM. Install the exact verified OmixOS
    # package from the image closure, launch its real Wails/WebKit window, and
    # remove it through the same profile ownership path as catalog apps.
    machine.succeed(as_omix("omarchy-pkg-add aether"))
    machine.succeed(as_omix("omarchy-pkg-present aether"))
    machine.succeed("test -f /home/omix/.nix-profile/share/applications/aether.desktop")
    machine.succeed(
        as_omix(
            "systemd-run --user --collect --unit=omixos-test-aether "
            "--property=Type=exec --property=ExitType=cgroup "
            "gtk-launch aether.desktop"
        )
    )
    machine.wait_until_succeeds(
        as_omix(
            "timeout 10s hyprctl clients -j | jq -e "
            "'any(.[]; (((.class // \"\") + \" \" + (.title // \"\")) "
            "| ascii_downcase | contains(\"aether\")))'"
        ),
        timeout=120,
    )
    machine.succeed(as_omix("systemctl --user stop omixos-test-aether.service"))
    machine.wait_until_succeeds(
        as_omix("timeout 10s hyprctl clients -j | jq -e 'length == 0'"),
        timeout=30,
    )
    machine.succeed(as_omix("omarchy-pkg-drop aether"))
    machine.fail(as_omix("omarchy-pkg-present aether"))

    # Launch the three native Quattro utilities through their desktop entries,
    # proving their packaged Qt plugins and app-library integration on ARM.
    for desktop_id, process_name in [
        ("omawrite.desktop", "omawrite"),
        ("omacalc.desktop", "omacalc"),
        ("omacut.desktop", "omacut"),
    ]:
        machine.succeed(
            as_omix(
                f"systemd-run --user --collect --unit=omixos-test-{process_name} "
                f"--property=Type=exec --property=ExitType=cgroup "
                f"gtk-launch {desktop_id}"
            )
        )
        machine.wait_until_succeeds(
            as_omix("timeout 10s hyprctl clients -j | jq -e 'length > 0'"),
            timeout=90,
        )
        machine.succeed(
            as_omix(f"systemctl --user stop omixos-test-{process_name}.service")
        )
        machine.wait_until_succeeds(
            as_omix("timeout 10s hyprctl clients -j | jq -e 'length == 0'"),
            timeout=30,
        )

    # Install a GUI application into the live user's pinned Nix profile,
    # discover its desktop entry in the current session, launch it through
    # gtk-launch, then uninstall it through the app-library ownership path.
    machine.succeed(
        as_omix(
            "OMIXOS_NIXPKGS_REF=path:${testNixpkgs}/share/omixos-test-nixpkgs "
            "OMIXOS_PKG_INSTALL_SELECTION=xterm "
            "omarchy-pkg-install xterm"
        )
    )
    machine.succeed("test -f /home/omix/.nix-profile/share/applications/xterm.desktop")
    machine.succeed(as_omix("omarchy-pkg-present xterm"))
    machine.succeed(
        as_omix(
            "systemd-run --user --collect --unit=omixos-test-xterm "
            "--property=Type=exec --property=ExitType=cgroup "
            "gtk-launch xterm.desktop"
        )
    )
    machine.wait_until_succeeds(
        as_omix(
            "timeout 10s hyprctl clients -j | jq -e "
            "'any(.[]; ((.class // \"\") | ascii_downcase | contains(\"xterm\")))'"
        ),
        timeout=60,
    )
    machine.succeed(as_omix("systemctl --user stop omixos-test-xterm.service"))
    machine.wait_until_succeeds(
        as_omix("timeout 10s hyprctl clients -j | jq -e 'length == 0'"),
        timeout=30,
    )
    machine.succeed(
        as_omix("omarchy-remove-launcher-entry xterm.desktop XTerm")
    )
    machine.succeed("test ! -e /home/omix/.nix-profile/share/applications/xterm.desktop")
    machine.fail(as_omix("omarchy-pkg-present xterm"))

    # The AArch64 TCG VM has software rendering and no interactive keyring
    # unlock. Set the wrapper's explicit test mode on the gtk-launch process;
    # real desktop sessions do not receive these concessions.
    for desktop_id in ["Linear.desktop", "Slack.desktop"]:
        machine.succeed(
            as_omix(
                f"env OMIXOS_GRAPHICAL_TEST=1 gtk-launch {desktop_id}"
            )
        )
        machine.wait_until_succeeds(
            as_omix("timeout 10s hyprctl clients -j | jq -e 'length > 0'"),
            timeout=180,
        )
        machine.succeed(as_omix("systemctl --user stop 'omarchy-webapp-*'"))
        machine.wait_until_succeeds(
            as_omix("timeout 10s hyprctl clients -j | jq -e 'length == 0'"),
            timeout=30,
        )

    machine.succeed(
        as_omix(
            "systemd-run --user --collect --unit=omixos-test-nautilus "
            "--property=Type=exec nautilus --new-window"
        )
    )
    machine.wait_until_succeeds(
        as_omix("timeout 10s hyprctl clients -j | jq -e 'length >= 1'"),
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
        as_omix("timeout 10s hyprctl layers -j | grep -F 'omarchy-notifications'"),
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
