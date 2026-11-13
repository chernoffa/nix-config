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
      noctalia = command: exec "noctalia msg ${command}";
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
    in
    {
      home.packages = [
        pkgs.grimblast
        pkgs.gpu-screen-recorder-gtk
        pkgs.libnotify
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

          # Blur behind Noctalia's surfaces and the launcher, ignoring their
          # nearly transparent pixels. Noctalia animates its own surfaces.
          layer_rule = [
            {
              match.namespace = "^(noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)|vicinae)$";
              blur = true;
              blur_popups = true;
              ignore_alpha = 0.5;
            }
            {
              match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
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
              match.class = "^(gcr-prompter|xdg-desktop-portal-gtk)$";
              dim_around = true;
            }
            {
              match.class = "^(dev\\.noctalia\\.Noctalia)$";
              float = true;
              size = [
                1080
                920
              ];
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
            (bind "SUPER + S" (noctalia "panel-toggle control-center"))
            (bind "SUPER + comma" (noctalia "settings-toggle"))
            (bind "SUPER + Escape" (noctalia "panel-toggle session"))
            (bind "SUPER + ALT + L" (noctalia "session lock"))

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

            # Through Noctalia, so its on-screen display shows the change.
            (held "XF86AudioRaiseVolume" (noctalia "volume-up"))
            (held "XF86AudioLowerVolume" (noctalia "volume-down"))
            (held "XF86MonBrightnessUp" (noctalia "brightness-up"))
            (held "XF86MonBrightnessDown" (noctalia "brightness-down"))
            (locked "XF86AudioMute" (noctalia "volume-mute"))
            (locked "XF86AudioMicMute" (noctalia "mic-mute"))
            (locked "XF86AudioPlay" (noctalia "media toggle"))
            (locked "XF86AudioNext" (noctalia "media next"))
            (locked "XF86AudioPrev" (noctalia "media previous"))
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

      services.cliphist.enable = true;

      # ALT + Tab window switcher, ordered by most recent use. hyprshell
      # registers the binding itself; its overview is left off since vicinae
      # is the launcher.
      services.hyprshell = {
        enable = true;
        settings = {
          version = 4;
          # Defaults to the current monitor only; show every window.
          windows.switch.filter_by = [ ];
        };
      };
    };
}
