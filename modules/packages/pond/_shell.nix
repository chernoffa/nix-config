{
  lib,
  stdenv,
  kdePackages,
  quickshell,
  pythonEnv,
  lockscreen,
  screenshot,
  wallpaper,
  brightnessctl,
  ddcutil,
  fastfetch,
  iw,
  jq,
  networkmanager,
  pulseaudio,
  wl-clipboard,
  zenity,
  tzdata,
  xkeyboard-config,
  src,
  version,
}:

let
  # Commands the QML and its helper scripts run by name. `qs` starts the
  # lock screen, inheriting the wrapper's QML import path.
  runtimeDeps = [
    pythonEnv
    quickshell
    brightnessctl
    ddcutil
    fastfetch
    jq
    networkmanager
    pulseaudio
    wl-clipboard
    zenity
  ];
  lockscreenDir = "${lockscreen}/share/pond-interface/lockscreen";
in
stdenv.mkDerivation {
  pname = "pond-shell";
  inherit src version;

  strictDeps = true;

  nativeBuildInputs = [ kdePackages.wrapQtAppsHook ];
  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtimageformats
    kdePackages.qtsvg
    lockscreen
    screenshot
    wallpaper
  ];

  dontConfigure = true;
  dontBuild = true;
  # pond-shell is wrapped explicitly below.
  dontWrapQtApps = true;

  postPatch = ''
    substituteInPlace config/niri/shell/config.kdl \
      --replace-fail '"qs -c pond-shell"' "\"$out/bin/pond-shell\"" \
      --replace-fail '"qs" "-c" "pond-shell"' "\"$out/bin/pond-shell\"" \
      --replace-fail '/usr/bin/qs -p /usr/share/pond-interface/lockscreen' ${lib.getExe lockscreen} \
      --replace-fail '/usr/bin/qs -d -p /usr/share/pond-interface/lockscreen' "${lib.getExe lockscreen} -d" \
      --replace-fail /usr/bin/vicinae vicinae
    # Copied into the user's config, so by name rather than store path.
    substituteInPlace config/niri/cfg/keybinds.kdl \
      --replace-fail '"qs" "-c" "pond-shell"' '"pond-shell"'
    substituteInPlace config/applications/pond-manual.desktop \
      --replace-fail 'qs -c pond-shell' $out/bin/pond-shell \
      --replace-fail /usr/share/pond-interface $out/share/pond-interface

    substituteInPlace shell/shell.qml \
      --replace-fail /usr/share/pond-interface/lockscreen ${lockscreenDir}
    substituteInPlace shell/settings/session.py \
      --replace-fail /usr/share/pond-interface/lockscreen ${lockscreenDir}
    substituteInPlace shell/wifi/State.qml \
      --replace-fail /usr/bin/nmcli ${lib.getExe' networkmanager "nmcli"} \
      --replace-fail /usr/bin/iw ${lib.getExe iw}
    substituteInPlace shell/settings/system/control.py \
      --replace-fail /usr/share/X11/xkb ${xkeyboard-config}/share/X11/xkb \
      --replace-fail /usr/share/zoneinfo ${tzdata}/share/zoneinfo
  '';

  installPhase = ''
    runHook preInstall

    share=$out/share/pond-interface
    mkdir -p $share/config
    cp -r shell $share/
    cp -r config/niri $share/config/
    # The shell runs ../wallpaper/control.py relative to itself.
    ln -s ${wallpaper}/share/pond-interface/wallpaper $share/wallpaper
    install -Dm644 config/applications/pond-manual.desktop -t $out/share/applications

    makeQtWrapper ${lib.getExe' quickshell "qs"} $out/bin/pond-shell \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --add-flags "-p $share/shell"

    runHook postInstall
  '';

  passthru = { inherit lockscreen screenshot wallpaper; };

  meta = {
    description = "Pond desktop shell for niri";
    homepage = "https://github.com/bflycomputer/pond-interface";
    license = lib.licenses.bsd3;
    mainProgram = "pond-shell";
    platforms = lib.platforms.linux;
  };
}
