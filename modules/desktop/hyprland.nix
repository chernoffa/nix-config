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

    # Screen recording; the module grants the capability it needs.
    programs.gpu-screen-recorder.enable = true;
  };

  flake.modules.homeManager.desktop =
    {
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
      # Skip launching a second copy while one is still running. Process names
      # are cut to 15 characters and Nix wrappers prefix a dot, so match on
      # the first 14.
      runOnce =
        program: args:
        exec "pgrep ${builtins.substring 0 14 program} || uwsm app -- ${program}${
          lib.optionalString (args != "") " ${args}"
        }";
      # Copy to the clipboard and save to the screenshots folder.
      areaScreenshot = runOnce "grimblast" "--freeze --notify copysave area";
      outputScreenshot = runOnce "grimblast" "--notify copysave output";
      record = runOnce "gpu-screen-recorder-gtk" "";
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
      spring = name: stiffness: dampening: {
        _args = [
          name
          {
            type = "spring";
            mass = 1;
            inherit stiffness dampening;
          }
        ];
      };
      # Translucent white text that reads on both wallpapers.
      lockLabel =
        attrs:
        {
          monitor = "";
          font_family = "Inter";
          halign = "center";
          valign = "center";
          shadow_color = "rgba(50, 50, 50, 0.1)";
          shadow_size = 20;
          shadow_passes = 2;
          shadow_boost = 0.3;
        }
        // attrs;
      wlogoutIcon = name: ''
        #${name} {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/${name}.png"));
        }
      '';
    in
    {
      home.packages = [
        pkgs.brightnessctl
        pkgs.grimblast
        pkgs.gpu-screen-recorder-gtk
        pkgs.libnotify
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
          # Fallback for monitors without a rule of their own; hosts add those.
          monitor = [
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = "auto";
            }
          ];

          # Show the cursor in screenshots.
          env = {
            _args = [
              "GRIMBLAST_NO_CURSOR"
              "0"
            ];
          };

          config = {
            general = {
              gaps_in = 4;
              gaps_out = 8;
              border_size = 1;
              resize_on_border = true;
              # Lets the `immediate` window rule below tear for lower latency.
              allow_tearing = true;
              layout = "dwindle";
            };
            # Tabbed window groups; theme.nix sets their colors.
            group.groupbar = {
              font_size = 12;
              font_weight_active = "bold";
              gradients = false;
              height = 20;
              indicator_height = 20;
              rounding = 10;
              rounding_power = 2.5;
              text_offset = -20;
            };
            decoration = {
              rounding = 10;
              # Squircle corners.
              rounding_power = 2.5;
              dim_inactive = true;
              dim_strength = 0.1;
              blur = {
                enabled = true;
                passes = 4;
                size = 7;
                noise = 0.01;
                vibrancy = 0.2;
                vibrancy_darkness = 0.5;
                popups = true;
                popups_ignorealpha = 0.2;
              };
              shadow = {
                enabled = true;
                color = "rgba(00000055)";
                offset = [
                  0
                  15
                ];
                range = 100;
                render_power = 2;
                scale = 0.97;
              };
            };
            animations.enabled = true;
            dwindle.preserve_split = true;
            input = {
              kb_layout = "us";
              follow_mouse = 1;
              focus_on_close = 1;
              accel_profile = "flat";
              touchpad.natural_scroll = true;
            };
            misc = {
              force_default_wallpaper = 0;
              animate_mouse_windowdragging = false;
              focus_on_activate = true;
              # Adaptive sync for fullscreen windows only.
              vrr = 2;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = true;
            };
          };

          # Springs: windows pop in and out, workspaces settle with a slight bounce.
          curve = [
            (spring "bounce" 350 30)
            (spring "winIn" 350 35)
            (spring "winOut" 320 32)
            (spring "winMove" 300 30)
          ];
          animation = [
            {
              leaf = "border";
              enabled = true;
              speed = 2;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 4;
              bezier = "default";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 1;
              spring = "bounce";
            }
            {
              leaf = "windowsIn";
              enabled = true;
              speed = 3;
              spring = "winIn";
              style = "popin 85%";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 3;
              spring = "winOut";
              style = "popin 85%";
            }
            {
              leaf = "windowsMove";
              enabled = true;
              speed = 3;
              spring = "winMove";
              style = "slide";
            }
          ];

          # Blur behind Quickshell's surfaces, the launcher, and the logout
          # menu, ignoring their nearly transparent pixels.
          layer_rule = [
            {
              match.namespace = "^(quickshell:notifications:overlay|quickshell:osd|quickshell:sidebar|quickshell:popup|vicinae|logout_dialog)$";
              blur = true;
            }
            {
              match.namespace = "^(quickshell:notifications:overlay|quickshell:osd)$";
              ignore_alpha = 0.2;
            }
            {
              match.namespace = "^(quickshell:sidebar|quickshell:popup|vicinae|logout_dialog)$";
              ignore_alpha = 0.5;
            }
            {
              match.namespace = "^quickshell.*$";
              blur_popups = true;
            }
            {
              match.namespace = "^(quickshell:bar)$";
              ignore_alpha = 0.1;
            }
            {
              match.namespace = "^(quickshell:notifications:overlay|quickshell:sidebar|quickshell:popup)$";
              no_anim = true;
            }
          ];

          window_rule = [
            {
              match.title = "^(Picture-in-Picture)$";
              float = true;
              pin = true;
            }
            {
              match.title = "^(Firefox — Sharing Indicator)$";
              workspace = "special silent";
            }
            {
              match.class = "^(gcr-prompter|xdg-desktop-portal-gtk|hyprpolkitagent)$";
              dim_around = true;
            }
            {
              match.class = "^(mpv|firefox)$";
              idle_inhibit = "fullscreen";
            }
            {
              match.xwayland = true;
              rounding = 0;
            }
            {
              match.class = "^(osu!|cs2)$";
              immediate = true;
            }
          ];

          bind = [
            (bind "SUPER + Return" (app "ghostty"))
            (bind "SUPER + Space" (exec "vicinae toggle"))
            (bind "SUPER + E" (app "dolphin"))
            (bind "SUPER + SHIFT + E" (app "ghostty -e yazi"))
            (bind "SUPER + C" (exec "cliphist list | vicinae dmenu | cliphist decode | wl-copy"))
            (bind "SUPER + Escape" (exec "wlogout"))
            (bind "SUPER + ALT + L" (exec "loginctl lock-session"))

            (bind "Print" areaScreenshot)
            (bind "SUPER + SHIFT + R" areaScreenshot)
            (bind "CTRL + Print" outputScreenshot)
            (bind "SUPER + SHIFT + CTRL + R" outputScreenshot)
            (bind "ALT + Print" record)
            (bind "SUPER + SHIFT + ALT + R" record)

            (bind "SUPER + G" "hl.dsp.group.toggle()")
            (bind "SUPER + SHIFT + N" "hl.dsp.group.next()")
            (bind "SUPER + SHIFT + P" "hl.dsp.group.prev()")

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

        # No gaps, borders, or rounding when a workspace has one tiled window;
        # SUPER + M toggles it.
        extraLuaFiles.smartgaps.content = ''
          local workspace_rules = {
            hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 }),
            hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 }),
          }
          local window_rules = {
            hl.window_rule({ name = "smartgaps-tv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 }),
            hl.window_rule({ name = "smartgaps-f1", match = { float = false, workspace = "f[1]" }, border_size = 0, rounding = 0 }),
          }

          hl.bind("SUPER + M", function()
            local enabled = not window_rules[1]:is_enabled()
            for _, rule in ipairs(workspace_rules) do
              rule:set_enabled(enabled)
            end
            for _, rule in ipairs(window_rules) do
              rule:set_enabled(enabled)
            end
          end)
        '';
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            immediate_render = true;
          };
          animation = [
            "inputFieldDots, 1, 2, linear"
            "fade, 0"
          ];
          background = {
            monitor = "";
            blur_passes = 2;
            blur_size = 4;
          };
          input-field = {
            monitor = "";
            size = "200, 36";
            position = "0%, 10%";
            halign = "center";
            valign = "bottom";
            outline_thickness = 1;
            font_color = "rgb(255, 255, 255)";
            outer_color = "rgba(255, 255, 255, 0.2)";
            inner_color = "rgba(100, 100, 100, 0.4)";
            check_color = "rgb(255, 200, 0)";
            fail_color = "rgb(255, 100, 100)";
            fade_on_empty = false;
            placeholder_text = "Enter Password";
            dots_spacing = 0.2;
            dots_center = true;
            dots_fade_time = 100;
            shadow_color = "rgba(50, 50, 50, 0.1)";
            shadow_size = 3;
            shadow_passes = 2;
          };
          label = [
            (lockLabel {
              text = "<b>$TIME</b>";
              font_size = 150;
              color = "rgba(255, 255, 255, 0.5)";
              position = "0%, 30%";
            })
            (lockLabel {
              text = "cmd[update:60000] date +'%A, %B %-d'";
              font_size = 20;
              color = "rgba(255, 255, 255, 0.4)";
              position = "0%, 40%";
            })
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
        style = ''
          * {
            background: none;
          }

          window {
            background-color: rgba(0, 0, 0, 0.5);
          }

          button {
            color: white;
            font-family: Inter;
            background-color: rgba(0, 0, 0, 0.05);
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
            border-radius: 12px;
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.1);
            margin: 1rem;
          }

          button:focus,
          button:active,
          button:hover {
            background-color: rgba(255, 255, 255, 0.2);
            outline-style: none;
          }

          ${lib.concatMapStrings wlogoutIcon [
            "lock"
            "logout"
            "suspend"
            "reboot"
            "shutdown"
          ]}
        '';
      };

      services.hyprpolkitagent.enable = true;
      services.cliphist.enable = true;
    };
}
