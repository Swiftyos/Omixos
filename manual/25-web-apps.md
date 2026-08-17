# Web Apps

The Quattro runtime can launch browser-backed apps in isolated windows with
`omarchy-launch-webapp`. The runtime's web-app desktop entries are immutable;
the user application directory is seeded into writable Home Manager state.

The current OmixOS profile contains **Linear** and **Slack** web apps. It
intentionally excludes **Basecamp** and **HEY** launchers. The desktop entries
are installed into the profile/application paths and can be launched in the
same session with `gtk-launch Linear.desktop` or `gtk-launch Slack.desktop`
after the menu refresh. Both launch paths passed the graphical VM; physical
Pi acceptance remains separate.

## Linear

Open Linear from the application launcher. It uses `https://linear.app` in the
system Chromium profile. Sign in through Chromium first when a service's
password-manager integration needs a full browser context.

## Slack

Open Slack from the application launcher. It uses
`https://app.slack.com/client` and the same isolated web-app wrapper.

## Adding a user web app

The upstream menu's interactive web-app installer is not a supported package
manager on OmixOS. Add a desktop entry through a private runtime/profile
overlay, or use a normal browser bookmark. Do not expect an Arch package or AUR
transaction to be performed by the menu.

When a web app is present, its hotkey and desktop entry can be overridden in
the writable Hyprland/application state. Physical Pi browser behavior remains
part of the acceptance list.
