# Fonts

OmixOS packages and registers the Omarchy icon/font assets declaratively. The
ARM core profile includes the runtime font path; it does not use an Arch
`omarchy pkg add` menu installer. Add another font through a NixOS/Home Manager
package or a writable user font directory, then rebuild or refresh the user
font cache as appropriate.

The Quattro theme system can still change the terminal, bar, and application
font settings through writable user configuration.
