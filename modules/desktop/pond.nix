{ config, ... }:

# Pond's desktop (github.com/bflycomputer/pond-interface) as a second
# session next to Hyprland: pick "Niri" on Pond's login screen. Pond's
# shell, lock screen, and idle handling run there in place of Hyprland's.
let
  hmModule = config.flake.modules.homeManager.pond;
in
{
  flake.modules.nixos.pond =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home-manager.sharedModules = [ hmModule ];

      programs.niri.enable = true;

      environment.systemPackages = [
        pkgs.pond.shell
        # The greeter theme, from share/sddm/themes.
        pkgs.pond.lockscreen
        # Set as the cursor theme by Pond's niri config.
        pkgs.capitaine-cursors
      ];

      fonts.packages = [
        pkgs.pond.onest
        pkgs.pond.advent-pro
        pkgs.ibm-plex
        pkgs.jetbrains-mono
      ];

      # Battery, power profiles, and DDC/CI monitor brightness in the sidebar.
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      hardware.i2c.enable = true;

      # Pond's login screen: SDDM showing the lock screen's greeter in a niri
      # instance of its own, as pond-lockscreen sets it up on Arch.
      services.greetd.enable = false;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "pond";
        # Pond.System and Pond.Daylight for the greeter, and SVG images.
        extraPackages = [
          pkgs.pond.lockscreen
          pkgs.pond.wallpaper
          pkgs.kdePackages.qtsvg
        ];
        settings.Wayland.CompositorCommand = "${lib.getExe config.programs.niri.package} --config ${pkgs.pond.lockscreen}/share/sddm/themes/pond/niri.kdl";
      };

      # NVIDIA's driver keeps freed buffers in niri's heap instead of handing
      # them back, so niri's video memory grows toward 1 GiB. The profile from
      # niri's wiki (docs/wiki/Nvidia.md) turns that reuse off.
      environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json" =
        lib.mkIf config.hardware.nvidia.enabled {
          text = builtins.toJSON {
            rules = [
              {
                pattern = {
                  feature = "procname";
                  matches = "niri";
                };
                profile = "Limit Free Buffer Pool On Wayland Compositors";
              }
            ];
            profiles = [
              {
                name = "Limit Free Buffer Pool On Wayland Compositors";
                settings = [
                  {
                    key = "GLVidHeapReuseRatio";
                    value = 0;
                  }
                ];
              }
            ];
          };
        };
    };

  flake.modules.homeManager.pond =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      niriConfig = "${pkgs.pond.shell}/share/pond-interface/config/niri";
      # Pond's personal settings, in the order its config.kdl includes them.
      personal = [
        "animation"
        "autostart"
        "keybinds"
        "input"
        "display"
        "layout"
        "rules"
        "misc"
      ];
      # Hyprland's bar, idle locker, and window switcher would run on top of
      # Pond's shell, since both sessions start graphical-session.target.
      hyprlandOnly.Unit.ConditionEnvironment = "!XDG_CURRENT_DESKTOP=niri";
    in
    {
      # Pond's config.kdl, with its shell part from the store and this
      # config's terminal and file manager in place of kitty and Nautilus.
      xdg.configFile."niri/config.kdl".text = ''
        include "${niriConfig}/shell/config.kdl"

        ${lib.concatMapStrings (name: ''
          include optional=true "./cfg/${name}.kdl"
        '') personal}
        binds {
            Mod+Return hotkey-overlay-title="Open Terminal: Ghostty" { spawn "ghostty"; }
            Mod+E hotkey-overlay-title="File Manager: Dolphin" { spawn "dolphin"; }
        }
      '';

      # Pond's settings app rewrites cfg/display.kdl and cfg/input.kdl in
      # place, so these start as writable copies of its defaults.
      home.activation.pondNiriConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p ${config.xdg.configHome}/niri/cfg
        for name in ${lib.concatStringsSep " " personal}; do
          file=${config.xdg.configHome}/niri/cfg/$name.kdl
          [ -e "$file" ] || run install -m644 ${niriConfig}/cfg/$name.kdl "$file"
        done
      '';

      systemd.user.services = {
        quickshell = hyprlandOnly;
        hyprshell = hyprlandOnly;
        # Keeps the module's own condition alongside.
        hypridle.Unit.ConditionEnvironment = lib.mkForce [
          "WAYLAND_DISPLAY"
          hyprlandOnly.Unit.ConditionEnvironment
        ];
      };
    };
}
