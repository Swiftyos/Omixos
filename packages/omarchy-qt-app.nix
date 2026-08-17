{
  lib,
  stdenv,
  qt6,
  ffmpeg,
  pipewire,
  makeWrapper,
  writeText,
  pname,
  version,
  src,
  withMultimedia ? false,
}:

let
  fallbackDesktop = writeText "${pname}.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=${pname}
    Exec=${pname}
    Icon=${pname}
    Terminal=false
    Categories=Utility;
  '';
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    makeWrapper
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ]
  ++ lib.optional withMultimedia qt6.qtmultimedia;

  buildPhase = ''
    runHook preBuild
    qmake6 ${pname}.pro
    make -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 ${pname} "$out/bin/${pname}"
    install -Dm644 LICENSE "$out/share/licenses/${pname}/LICENSE"
    if [[ -f "pkgbuild/${pname}.desktop" ]]; then
      install -Dm644 "pkgbuild/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    else
      install -Dm644 ${fallbackDesktop} "$out/share/applications/${pname}.desktop"
    fi
    if [[ -f "pkgbuild/${pname}.svg" ]]; then
      install -Dm644 "pkgbuild/${pname}.svg" "$out/share/icons/hicolor/scalable/apps/${pname}.svg"
    fi
    runHook postInstall
  '';

  postFixup = lib.optionalString withMultimedia ''
    wrapProgram "$out/bin/${pname}" \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pipewire ]}
  '';

  meta = {
    description = "Native Omarchy ${pname} application";
    homepage = "https://github.com/omacom-io/${pname}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = pname;
  };
}
