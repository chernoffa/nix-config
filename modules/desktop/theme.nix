# Noctalia's palette, dark by night and light by day. Noctalia flips the
# freedesktop color-scheme at sunset and sunrise and renders its templates
# for GTK, Qt, Ghostty, and Hyprland; apps that follow the color-scheme
# (Firefox, Vicinae, bat, Yazi) switch on their own.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      fonts = {
        packages = [
          pkgs.berkeley-mono
          pkgs.inter
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts-color-emoji
        ];
        fontconfig.defaultFonts = {
          sansSerif = [ "Inter" ];
          monospace = [
            "Berkeley Mono"
            # Fallback for Nerd Font glyphs.
            "JetBrainsMono Nerd Font"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      # The color-scheme and GTK theme preferences live in dconf.
      programs.dconf.enable = true;

      boot = {
        plymouth.enable = true;
        # Keep kernel and udev messages from scrolling over the splash.
        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "systemd.show_status=auto"
          "rd.udev.log_level=3"
          # Draw the splash before the NVIDIA driver loads.
          "plymouth.use-simpledrm"
        ];
      };
    };

  flake.modules.homeManager.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      gsettings = lib.getExe' pkgs.glib "gsettings";
      qt6ct = "${config.xdg.configHome}/qt6ct";
      # Noctalia's templates color GTK and Qt but leave the icon theme, so
      # pick the Papirus variant for the mode, which arrives as $1. Qt apps
      # pick it up when they next start.
      iconTheme = pkgs.writeShellScript "noctalia-icon-theme" ''
        if [ "$1" = light ]; then icons=Papirus-Light; else icons=Papirus-Dark; fi
        ${gsettings} set org.gnome.desktop.interface icon-theme "$icons"
        mkdir -p ${qt6ct}
        printf '[Appearance]\ncolor_scheme_path=%s\ncustom_palette=true\nicon_theme=%s\nstandard_dialogs=xdgdesktopportal\nstyle=Breeze\n' \
          ${qt6ct}/colors/noctalia.conf "$icons" > ${qt6ct}/qt6ct.conf
      '';
    in
    {
      home.pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
      };

      gtk = {
        enable = true;
        font = {
          name = "Inter";
          size = 11;
        };
        # Noctalia's GTK template switches to adw-gtk3 in light mode.
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        # GTK4 takes its colors from Noctalia's template.
        gtk4.theme = null;
      };

      # Dolphin: qt6ct's config is written by the icon theme script above.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style = {
          name = "breeze";
          package = pkgs.kdePackages.breeze;
        };
      };

      # Hyprland draws no title bars, so let Qt windows be dragged from any
      # empty area, not just their menu bar and main toolbar.
      xdg.configFile.breezerc.text = ''
        [Style]
        WindowDragMode=WD_FULL
      '';

      programs.noctalia.settings = {
        theme = {
          mode = "auto";
          source = "builtin";
          builtin = "Noctalia";
          sync_color_scheme = true;
          templates = {
            enable_builtin_templates = true;
            builtin_ids = [
              "ghostty"
              "gtk3"
              "gtk4"
              "hyprland"
              "qt"
            ];
            # Renders the mode so the hook reruns whenever it changes.
            user.icon-theme = {
              input_path = "${pkgs.writeText "noctalia-mode" "{{ mode }}\n"}";
              output_path = "${config.xdg.stateHome}/noctalia/mode";
              post_hook = "${iconTheme} {{ mode }}";
            };
          };
        };
        # Sunset and sunrise for the dark and light modes.
        location = {
          latitude = 37.37;
          longitude = -122.04;
        };
      };

      # Border and group colors from Noctalia's Hyprland template, once it
      # has written noctalia.lua. Its hook appends require("noctalia") to
      # this file unless it's already here.
      wayland.windowManager.hyprland.extraConfig = ''
        pcall(function() require("noctalia").apply_theme() end)
      '';

      # Rerender the templates after a rebuild, since activation writes the
      # dark GTK theme back to dconf.
      home.activation.noctaliaTemplates = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
        run ${lib.getExe config.programs.noctalia.package} msg templates-apply || true
      '';
    };
}
