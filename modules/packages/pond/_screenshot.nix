{
  lib,
  stdenv,
  cmake,
  ninja,
  kdePackages,
  src,
  version,
}:

stdenv.mkDerivation {
  pname = "pond-screenshot";
  inherit src version;

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
  ];
  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtdeclarative
  ];

  cmakeDir = "../screenshot/native";

  # Only a QML plugin; nothing to wrap.
  dontWrapQtApps = true;

  postPatch = ''
    substituteInPlace screenshot/native/CMakeLists.txt \
      --replace-fail lib/qt6/qml ${kdePackages.qtbase.qtQmlPrefix}
  '';

  postInstall = ''
    module=$out/${kdePackages.qtbase.qtQmlPrefix}/Pond/Screenshot
    install -Dm644 ../screenshot/{qmldir,State.qml,Preview.qml,clipboard.py} -t $module
    install -Dm644 ../screenshot/assets/*.svg -t $module/assets
  '';

  meta = {
    description = "Default screenshotting tool for Pond";
    homepage = "https://github.com/bflycomputer/pond-interface";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
