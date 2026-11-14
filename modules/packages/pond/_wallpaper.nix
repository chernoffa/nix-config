{
  lib,
  stdenvNoCC,
  kdePackages,
  src,
  version,
}:

stdenvNoCC.mkDerivation {
  pname = "pond-wallpaper";
  inherit src version;

  strictDeps = true;

  nativeBuildInputs = [ kdePackages.qtshadertools ];
  # Only QML and data files; qsb just compiles the shader.
  dontWrapQtApps = true;

  buildPhase = ''
    runHook preBuild
    qsb --qt6 -o wallpaper/daylight/sky.frag.qsb wallpaper/daylight/sky.frag
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    qml=$out/${kdePackages.qtbase.qtQmlPrefix}/Pond
    install -Dm644 wallpaper/daylight/{Sky.qml,SkyState.js,qmldir,sky.frag.qsb} -t $qml/Daylight
    install -Dm644 wallpaper/desktop/{qmldir,Window.qml,Content.qml,Reveal.qml,*.qsb} -t $qml/Wallpaper

    share=$out/share/pond-interface/wallpaper
    install -Dm755 wallpaper/control.py -t $share
    install -Dm644 wallpaper/catalog.json -t $share
    install -Dm644 wallpaper/included/*.jpg -t $share/included

    runHook postInstall
  '';

  meta = {
    description = "Wallpaper manager for Pond";
    homepage = "https://github.com/bflycomputer/pond-interface";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
