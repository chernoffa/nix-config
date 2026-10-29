{
  # Bar, notification center, and on-screen display.
  flake.modules.homeManager.desktop = {
    services.wayle = {
      enable = true;
      autoInstallDependencies = true;
      settings = {
        bar.layout = [
          {
            monitor = "*";
            left = [
              "dashboard"
              "hyprland-workspaces"
              "window-title"
            ];
            center = [ "clock" ];
            right = [
              "media"
              "systray"
              "network"
              "bluetooth"
              "volume"
              "notifications"
              "power"
            ];
          }
        ];
        modules = {
          dashboard.dropdown-logout-command = "uwsm stop";
          power.left-click = "wlogout";
          volume.right-click = "pwvucontrol";
        };
      };
    };
  };
}
