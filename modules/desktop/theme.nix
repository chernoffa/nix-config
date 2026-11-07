# Catppuccin Mocha by night and Latte by day. darkman flips the freedesktop
# color-scheme at sunset and sunrise; apps that follow it (GTK4, Firefox,
# Ghostty, Vicinae, bat, Yazi) switch on their own, and the scripts below
# switch the rest.
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      fonts = {
        packages = [
          pkgs.inter
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts-color-emoji
        ];
        fontconfig.defaultFonts = {
          sansSerif = [ "Inter" ];
          monospace = [ "JetBrainsMono Nerd Font" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

      # The color-scheme and GTK theme preferences live in dconf.
      programs.dconf.enable = true;

      boot = {
        plymouth = {
          enable = true;
          theme = "catppuccin-mocha";
          themePackages = [ (pkgs.catppuccin-plymouth.override { variant = "mocha"; }) ];
        };
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
      osConfig,
      pkgs,
      lib,
      ...
    }:
    let
      hyprctl = lib.getExe' osConfig.programs.hyprland.package "hyprctl";
      gsettings = lib.getExe' pkgs.glib "gsettings";
      wallpaper = {
        dark = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;
        light = pkgs.nixos-artwork.wallpapers.catppuccin-latte.gnomeFilePath;
      };
      # Copied from Wayle's built-in catppuccin-mocha and catppuccin-latte.
      waylePalette = {
        dark = {
          bg = "#11111b";
          surface = "#181825";
          elevated = "#1e1e2e";
          fg = "#cdd6f4";
          fg-muted = "#bac2de";
          primary = "#b4befe";
          red = "#f38ba8";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          blue = "#74c7ec";
        };
        light = {
          bg = "#eff1f5";
          surface = "#e6e9ef";
          elevated = "#dce0e8";
          fg = "#4c4f69";
          fg-muted = "#5c5f77";
          primary = "#7287fd";
          red = "#d20f39";
          yellow = "#df8e1d";
          green = "#40a02b";
          blue = "#1e66f5";
        };
      };
      # TOML inline table for `wayle config set`.
      toInlineToml =
        attrs: "{ ${lib.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = \"${v}\"") attrs)} }";
      kvantumTheme = variant: {
        name = "Kvantum/catppuccin-${variant}-lavender";
        value.source = "${
          pkgs.catppuccin-kvantum.override {
            inherit variant;
            accent = "lavender";
          }
        }/share/Kvantum/catppuccin-${variant}-lavender";
      };
      # hyprlock reads the wallpaper through this link, which darkman repoints.
      wallpaperLink = "${config.xdg.stateHome}/wallpaper";
      # Mode scripts receive "dark" or "light" as $1.
      byMode = values: ''
        case "$1" in
          light) ${values.light} ;;
          *) ${values.dark} ;;
        esac
      '';
    in
    {
      xdg.configFile = lib.listToAttrs (
        map kvantumTheme [
          "mocha"
          "latte"
        ]
      );

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
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        # GTK4 follows the color-scheme without a theme.
        gtk4.theme = null;
      };

      # Dolphin: qt6ct and Kvantum configs are written by darkman below.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      wayland.windowManager.hyprland.extraLuaFiles.theme.content = ''
        local borders = {
          dark = { active_border = "rgba(88888888)", inactive_border = "rgba(00000088)" },
          light = { active_border = "rgba(00000088)", inactive_border = "rgba(00000000)" },
        }

        -- Called by darkman through `hyprctl eval`.
        function apply_theme(mode)
          hl.config({ general = { col = borders[mode] or borders.dark } })
        end

        -- On config reloads, keep the current mode.
        local ok, mode = pcall(function()
          local cache = os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")
          local file = io.open(cache .. "/darkman/mode.txt")
          local value = file:read("l")
          file:close()
          return value
        end)
        apply_theme(ok and mode or "dark")
      '';

      # Start once Hyprland's environment is in the user manager.
      systemd.user.services.darkman.Unit.After = [ "graphical-session.target" ];

      services.darkman = {
        enable = true;
        settings = {
          lat = 37.37;
          lng = -122.04;
          usegeoclue = false;
        };
        scripts = {
          color-scheme = ''
            ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-$1'"
          '';
          gtk3 = byMode {
            dark = ''
              ${gsettings} set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
              ${gsettings} set org.gnome.desktop.interface icon-theme Papirus-Dark
            '';
            light = ''
              ${gsettings} set org.gnome.desktop.interface gtk-theme adw-gtk3
              ${gsettings} set org.gnome.desktop.interface icon-theme Papirus-Light
            '';
          };
          # Qt apps pick these up when they next start.
          qt = ''
            if [ "$1" = light ]; then
              kvantum=catppuccin-latte-lavender icons=Papirus-Light
            else
              kvantum=catppuccin-mocha-lavender icons=Papirus-Dark
            fi
            mkdir -p ${config.xdg.configHome}/Kvantum ${config.xdg.configHome}/qt6ct
            printf '[General]\ntheme=%s\n' "$kvantum" > ${config.xdg.configHome}/Kvantum/kvantum.kvconfig
            printf '[Appearance]\nicon_theme=%s\nstandard_dialogs=xdgdesktopportal\nstyle=kvantum\n' "$icons" \
              > ${config.xdg.configHome}/qt6ct/qt6ct.conf
          '';
          hyprland = ''
            ${hyprctl} eval "apply_theme('$1')" || true
          '';
          wayle = byMode (
            lib.mapAttrs (
              _: palette:
              "${lib.getExe config.services.wayle.package} config set styling.palette '${toInlineToml palette}'"
            ) waylePalette
          );
          wallpaper = ''
            if [ "$1" = light ]; then image=${wallpaper.light}; else image=${wallpaper.dark}; fi
            ln -sfn "$image" ${wallpaperLink}
            # Wayle's wallpaper daemon may still be starting at login.
            for _ in $(seq 20); do
              ${lib.getExe config.services.wayle.package} wallpaper set "$image" && break
              sleep 0.5
            done
          '';
        };
      };

      # Rerun the mode scripts after a rebuild, since activation writes the
      # dark GTK theme back to dconf.
      home.activation.darkman = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
        run ${pkgs.systemd}/bin/systemctl --user try-restart darkman.service || true
      '';

      # Give hyprlock a wallpaper before darkman's first run.
      home.activation.wallpaperLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # -e is false for a dangling link too, e.g. after the old wallpaper is
        # garbage-collected; -f replaces it.
        [ -e ${wallpaperLink} ] || run ln -sfn ${wallpaper.dark} ${wallpaperLink}
      '';

      programs.hyprlock.settings.background.path = wallpaperLink;

      services.wayle.settings = {
        general = {
          font-sans = "Inter";
          font-mono = "JetBrainsMono Nerd Font";
        };
        styling.palette = waylePalette.dark;
        # Translucent so the compositor blur shows through.
        bar.background-opacity = 80;
        wallpaper = {
          transition-type = "grow";
          transition-duration = 1.5;
        };
      };
    };
}
