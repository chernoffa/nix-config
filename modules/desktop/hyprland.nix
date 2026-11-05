{
  flake.modules.nixos.desktop = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # Hint Electron/Chromium apps to use Wayland.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Real-time scheduling for PipeWire, which Hyprland enables.
    security.rtkit.enable = true;
  };

  flake.modules.homeManager.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (import ./_hyprland-lua.nix lib)
        bind
        bindWith
        exec
        app
        ;
      screenshot = mode: exec "hyprshot --mode ${mode} --raw | satty --filename -";
      dpms = action: "hyprctl dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
      directions = [
        "left"
        "right"
        "up"
        "down"
      ];
      workspaces = builtins.genList (i: toString (i + 1)) 9;
      # Media keys repeat while held and work while locked.
      locked = bindWith { locked = true; };
      held = bindWith {
        locked = true;
        repeating = true;
      };
      mouse = bindWith { mouse = true; };
    in
    {
      home.packages = [
        pkgs.brightnessctl
        pkgs.hyprshot
        pkgs.playerctl
        pkgs.wl-clipboard
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        # Use the packages from the NixOS module.
        package = null;
        portalPackage = null;
        # UWSM manages the session's systemd targets.
        systemd.enable = false;

        settings = {
          monitor = {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = "auto";
          };

          config = {
            general = {
              gaps_in = 4;
              gaps_out = 8;
              border_size = 2;
              layout = "dwindle";
            };
            decoration.rounding = 6;
            dwindle.preserve_split = true;
            input = {
              kb_layout = "us";
              follow_mouse = 1;
              touchpad.natural_scroll = true;
            };
            misc.force_default_wallpaper = 0;
          };

          bind = [
            (bind "SUPER + Return" (app "ghostty"))
            (bind "SUPER + Space" (exec "fuzzel"))
            (bind "SUPER + E" (app "dolphin"))
            (bind "SUPER + SHIFT + E" (app "ghostty -e yazi"))
            (bind "SUPER + C" (exec "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
            (bind "SUPER + Escape" (exec "wlogout"))
            (bind "SUPER + ALT + L" (exec "loginctl lock-session"))

            (bind "Print" (screenshot "region"))
            (bind "SHIFT + Print" (screenshot "window"))
            (bind "CTRL + Print" (screenshot "output"))

            (bind "SUPER + Q" "hl.dsp.window.close()")
            (bind "SUPER + F" "hl.dsp.window.fullscreen()")
            (bind "SUPER + V" "hl.dsp.window.float({ action = \"toggle\" })")
            (bind "SUPER + P" "hl.dsp.window.pseudo()")
            (bind "SUPER + J" "hl.dsp.layout(\"togglesplit\")")

            (mouse "SUPER + mouse:272" "hl.dsp.window.drag()")
            (mouse "SUPER + mouse:273" "hl.dsp.window.resize()")

            (held "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
            (held "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
            (held "XF86MonBrightnessUp" (exec "brightnessctl set 5%+"))
            (held "XF86MonBrightnessDown" (exec "brightnessctl set 5%-"))
            (locked "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            (locked "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
            (locked "XF86AudioPlay" (exec "playerctl play-pause"))
            (locked "XF86AudioNext" (exec "playerctl next"))
            (locked "XF86AudioPrev" (exec "playerctl previous"))
          ]
          ++ lib.concatMap (dir: [
            (bind "SUPER + ${dir}" "hl.dsp.focus({ direction = \"${dir}\" })")
            (bind "SUPER + SHIFT + ${dir}" "hl.dsp.window.move({ direction = \"${dir}\" })")
          ]) directions
          ++ lib.concatMap (ws: [
            (bind "SUPER + ${ws}" "hl.dsp.focus({ workspace = ${ws} })")
            (bind "SUPER + SHIFT + ${ws}" "hl.dsp.window.move({ workspace = ${ws} })")
          ]) workspaces;
        };
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general.hide_cursor = true;
          background.blur_passes = 2;
          input-field = {
            monitor = "";
            size = "300, 50";
            position = "0, -80";
            halign = "center";
            valign = "center";
          };
          label = [
            {
              monitor = "";
              text = "$TIME";
              font_size = 72;
              position = "0, 80";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = dpms "on";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = dpms "off";
              on-resume = dpms "on";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      programs.satty = {
        enable = true;
        settings.general = {
          early-exit = true;
          copy-command = "wl-copy";
          output-filename = "${config.xdg.userDirs.pictures}/screenshot-%Y%m%d-%H%M%S.png";
        };
      };

      programs.wlogout = {
        enable = true;
        layout = [
          {
            label = "lock";
            action = "loginctl lock-session";
            text = "Lock";
            keybind = "l";
          }
          {
            label = "logout";
            action = "uwsm stop";
            text = "Logout";
            keybind = "e";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
        ];
      };

      services.hyprpolkitagent.enable = true;
      services.cliphist.enable = true;
    };
}
