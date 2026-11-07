{
  # Bar, notifications, on-screen display, and calendar sidebar; see
  # _quickshell/README.md.
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      fonts.packages = [ pkgs.material-symbols ];
    };

  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    let
      # Commands the QML runs.
      dependencies = [
        pkgs.bash
        pkgs.coreutils
        pkgs.dconf
        pkgs.gawk
        pkgs.lsof
        pkgs.procps
        pkgs.ripgrep
        pkgs.util-linux
      ];
      qmlImportPath = lib.makeSearchPath "lib/qt-6/qml" [
        pkgs.quickshell
        pkgs.kdePackages.qtdeclarative
        pkgs.kdePackages.kirigami.unwrapped
      ];
    in
    {
      home.packages = [ pkgs.quickshell ];

      xdg.configFile.quickshell.source = ./_quickshell;

      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          X-Restart-Triggers = [ "${./_quickshell}" ];
        };
        Service = {
          Environment = [
            "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}"
            "QML2_IMPORT_PATH=${qmlImportPath}"
          ];
          ExecStart = lib.getExe pkgs.quickshell;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
