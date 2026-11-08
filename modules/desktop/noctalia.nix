{
  # Bar, notifications, on-screen display, launcher panels, lock screen,
  # session menu, wallpaper, idle, and polkit prompts. theme.nix sets its
  # colors and templates.
  flake.modules.nixos.desktop = {
    # Noctalia's power and battery widgets read from UPower.
    services.upower.enable = true;
  };

  flake.modules.homeManager.desktop =
    { config, ... }:
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        # Defaults; changes made in Noctalia's settings window are saved to
        # ~/.local/state/noctalia/settings.toml and take precedence.
        settings = {
          shell = {
            # Launch apps in their own systemd units, rather than inside
            # Noctalia's service, where restarting Noctalia would kill them.
            launch_apps_as_systemd_services = true;
            polkit_agent = true;
          };

          wallpaper = {
            enabled = true;
            fill_mode = "crop";
            # Kept out of the repo, since it isn't ours to redistribute.
            default.path = "${config.home.homeDirectory}/Pictures/Wallpapers/windows-core-essential.jpg";
          };

          # Noctalia also locks before any suspend, through logind.
          idle = {
            behavior_order = [
              "lock"
              "screen-off"
              "suspend"
            ];
            behavior = {
              lock = {
                timeout = 300;
                action = "lock";
              };
              screen-off = {
                timeout = 330;
                action = "screen_off";
              };
              suspend = {
                timeout = 1800;
                action = "lock_and_suspend";
              };
            };
          };
        };
      };

      # Hosts the system tray, so tray apps (tray.target) start after it.
      systemd.user.services.noctalia = {
        Unit = {
          PartOf = [ "tray.target" ];
          Before = [ "tray.target" ];
        };
        Install.WantedBy = [ "tray.target" ];
      };
    };
}
