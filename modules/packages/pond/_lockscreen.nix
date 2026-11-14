{
  lib,
  stdenv,
  cmake,
  ninja,
  kdePackages,
  wayland,
  coreutils,
  getent,
  quickshell,
  wallpaper,
  src,
  version,
}:

# The session lock (run by Quickshell, as pond-lockscreen) and the SDDM
# greeter theme "pond", which share one QML frontend and the Pond.System
# plugin.
stdenv.mkDerivation {
  pname = "pond-lockscreen";
  inherit src version;

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.wrapQtAppsHook
  ];
  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.networkmanager-qt
    wayland
    # Pond.Daylight, which the frontend draws behind the form.
    wallpaper
  ];

  # The plugin finds its backing library through $ORIGIN.
  cmakeFlags = [ (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_RPATH" true) ];
  ninjaFlags = [ "pond_systemplugin" ];

  # pond-lockscreen is wrapped explicitly below.
  dontWrapQtApps = true;

  postPatch = ''
    substituteInPlace lockscreen/session/SessionInfo.qml \
      --replace-fail /usr/bin/id ${lib.getExe' coreutils "id"} \
      --replace-fail /usr/bin/getent ${lib.getExe' getent "getent"}
    substituteInPlace lockscreen/session/Shell.qml \
      --replace-fail /usr/bin/systemctl systemctl

    # SDDM loads the theme from share/sddm/themes, away from the frontend.
    substituteInPlace lockscreen/greeter/Main.qml \
      --replace-fail '"../frontend"' "\"$out/share/pond-interface/lockscreen/frontend\""
  '';

  # The project has no install rules; this follows pond-pkgbuilds.
  installPhase = ''
    runHook preInstall

    share=$out/share/pond-interface
    mkdir -p $share/lockscreen
    cp -r ../lockscreen/{frontend,session,shell.qml} $share/lockscreen/
    # C++ sources of the plugin.
    rm -r $share/lockscreen/frontend/system

    module=$out/${kdePackages.qtbase.qtQmlPrefix}/Pond/System
    install -Dm755 libpond_system.so Pond/System/libpond_systemplugin.so -t $module
    install -Dm644 Pond/System/{qmldir,pond_system.qmltypes} -t $module

    install -Dm644 ../lockscreen/greeter/{Main.qml,metadata.desktop,niri.kdl} \
      -t $out/share/sddm/themes/pond

    makeQtWrapper ${lib.getExe' quickshell "qs"} $out/bin/pond-lockscreen \
      --prefix QML2_IMPORT_PATH : $out/${kdePackages.qtbase.qtQmlPrefix} \
      --add-flags "-p $share/lockscreen"

    runHook postInstall
  '';

  meta = {
    description = "Pond session lock and SDDM greeter";
    homepage = "https://github.com/bflycomputer/pond-interface";
    license = lib.licenses.bsd3;
    mainProgram = "pond-lockscreen";
    platforms = lib.platforms.linux;
  };
}
