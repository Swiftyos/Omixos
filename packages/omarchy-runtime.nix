{
  lib,
  stdenvNoCC,
  makeWrapper,
  bash,
  coreutils,
  curl,
  dbus,
  file,
  findutils,
  gawk,
  git,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  inetutils,
  jq,
  less,
  libnotify,
  perl,
  procps,
  python3,
  socat,
  systemd,
  unzip,
  util-linux,
  which,
  xdg-utils,
  omarchySrc,
}:

let
  upstreamRevision = "30f7a06090dc20dd1a4a8d0c99bfb8e2370df2ec";
  runtimeDependencies = [
    bash
    coreutils
    curl
    dbus
    file
    findutils
    gawk
    git
    gnugrep
    gnused
    gnutar
    gzip
    inetutils
    jq
    less
    libnotify
    perl
    procps
    python3
    socat
    systemd
    unzip
    util-linux
    which
    xdg-utils
  ];
in
stdenvNoCC.mkDerivation {
  pname = "omarchy-runtime";
  version = "quattro-${builtins.substring 0 12 upstreamRevision}";

  src = omarchySrc;
  nativeBuildInputs = [
    makeWrapper
    python3
  ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    runtime="$out/share/omarchy"
    mkdir -p "$runtime" "$out/bin"

    for tree in bin config default themes applications shell; do
      cp -R "$src/$tree" "$runtime/$tree"
    done

    for asset in LICENSE logo.txt logo.svg icon.txt icon.png; do
      if [[ -e "$src/$asset" ]]; then
        cp -R "$src/$asset" "$runtime/$asset"
      fi
    done

    printf '%s\n' '${upstreamRevision}' > "$runtime/UPSTREAM_REVISION"
    chmod -R u+w "$runtime"
    find "$runtime/bin" -type f -exec chmod 0755 {} +
    patchShebangs "$runtime/bin" "$runtime/shell"

    # Replace Arch/system-mutating entry points with an explicit NixOS boundary.
    # The source remains packaged for attribution and inventory, but these paths
    # must never invoke Pacman, edit /etc, or change boot configuration on NixOS.
    for command in \
      "$runtime/bin"/omarchy-apply-* \
      "$runtime/bin"/omarchy-channel-* \
      "$runtime/bin"/omarchy-brightness-display-apple \
      "$runtime/bin"/omarchy-dev-add-migration \
      "$runtime/bin"/omarchy-dev-install-ydoo \
      "$runtime/bin"/omarchy-dev-link \
      "$runtime/bin"/omarchy-dev-pkg-test \
      "$runtime/bin"/omarchy-dev-status \
      "$runtime/bin"/omarchy-dev-unlink \
      "$runtime/bin"/omarchy-dns \
      "$runtime/bin"/omarchy-drive-password \
      "$runtime/bin"/omarchy-hibernation-remove \
      "$runtime/bin"/omarchy-hibernation-setup \
      "$runtime/bin"/omarchy-install-* \
      "$runtime/bin"/omarchy-menu-timezone \
      "$runtime/bin"/omarchy-pkg-* \
      "$runtime/bin"/omarchy-plymouth-* \
      "$runtime/bin"/omarchy-provision-* \
      "$runtime/bin"/omarchy-refresh-limine \
      "$runtime/bin"/omarchy-refresh-pacman \
      "$runtime/bin"/omarchy-refresh-plymouth \
      "$runtime/bin"/omarchy-refresh-sddm \
      "$runtime/bin"/omarchy-reinstall \
      "$runtime/bin"/omarchy-reinstall-* \
      "$runtime/bin"/omarchy-remove-browser \
      "$runtime/bin"/omarchy-remove-dev-env \
      "$runtime/bin"/omarchy-remove-gaming-* \
      "$runtime/bin"/omarchy-remove-security-* \
      "$runtime/bin"/omarchy-remove-service-* \
      "$runtime/bin"/omarchy-setup-direct-boot \
      "$runtime/bin"/omarchy-setup-security-* \
      "$runtime/bin"/omarchy-snapshot \
      "$runtime/bin"/omarchy-sudo-* \
      "$runtime/bin"/omarchy-system-factory-reset \
      "$runtime/bin"/omarchy-system-factory-reset-finish \
      "$runtime/bin"/omarchy-toggle-hybrid-gpu \
      "$runtime/bin"/omarchy-update* \
      "$runtime/bin"/omarchy-upgrade-to-quattro \
      "$runtime/bin"/omarchy-voxtype-* \
      "$runtime/bin"/omarchy-windows-vm; do
      [[ -e "$command" ]] || continue
      install -m 0755 ${./overrides/omarchy-nixos-unsupported} "$command"
    done

    install -m 0755 ${./overrides/omarchy-update} "$runtime/bin/omarchy-update"
    install -m 0755 ${./overrides/omarchy-update-available} "$runtime/bin/omarchy-update-available"
    install -m 0755 ${./overrides/omarchy-pkg-present} "$runtime/bin/omarchy-pkg-present"
    install -m 0755 ${./overrides/omarchy-pkg-missing} "$runtime/bin/omarchy-pkg-missing"
    install -m 0755 ${./overrides/omarchy-provision-first-run} "$runtime/bin/omarchy-provision-first-run"
    install -m 0755 ${./overrides/omarchy-migrate} "$runtime/bin/omarchy-migrate"
    install -m 0755 ${./overrides/omarchy-debug} "$runtime/bin/omarchy-debug"
    install -m 0755 ${./overrides/omarchy-default-browser} "$runtime/bin/omarchy-default-browser"
    install -m 0755 ${./overrides/omarchy-launch-browser} "$runtime/bin/omarchy-launch-browser"
    install -m 0755 ${./overrides/omarchy-version} "$runtime/bin/omarchy-version"

    mkdir -p "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"
    cp "$runtime"/applications/*.desktop "$out/share/applications/"
    for icon in "$runtime"/applications/icons/*.png; do
      icon_name="$(basename "''${icon%.png}" | tr '[:upper:] ' '[:lower:]-')"
      install -m 0644 "$icon" "$out/share/icons/hicolor/256x256/apps/$icon_name.png"
    done

    patchShebangs "$runtime/bin"

    for program in "$runtime/bin"/omarchy*; do
      [[ -x "$program" ]] || continue
      name="$(basename "$program")"
      makeWrapper "$program" "$out/bin/$name" \
        --set OMARCHY_PATH "$runtime" \
        --prefix PATH : "$runtime/bin:${lib.makeBinPath runtimeDependencies}"
    done

    runHook postInstall
  '';

  passthru = {
    inherit runtimeDependencies upstreamRevision;
    omarchyPath = "${placeholder "out"}/share/omarchy";
  };

  meta = {
    description = "Immutable Omarchy quattro runtime adapted for NixOS";
    homepage = "https://github.com/basecamp/omarchy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
