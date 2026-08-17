# Fonts

OmixOS packages and registers the Omarchy icon/font assets declaratively. The
ARM core profile includes the runtime font path; it does not use an Arch
`omarchy pkg add` menu installer. `omarchy-pkg-install` searches the pinned
Nixpkgs set for a font and installs it into the current user's profile; add a
system-wide font through NixOS/Home Manager or a writable user font directory,
then refresh the user font cache as appropriate.

The Quattro theme system can still change the terminal, bar, and application
font settings through writable user configuration.
