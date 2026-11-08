{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      # Dolphin outside of Plasma: thumbnails, network mounts, and SVG icons,
      # plus Ark for its "Extract" and "Compress" menus.
      environment.systemPackages = [
        pkgs.kdePackages.ark
        pkgs.kdePackages.dolphin
        pkgs.kdePackages.kio-extras
        pkgs.kdePackages.kio-fuse
        pkgs.kdePackages.qtsvg
      ];

      # Without a Plasma menu file, Dolphin's "Open With" list is empty.
      # Copied out so plasma-workspace stays out of the system closure.
      environment.etc."xdg/menus/applications.menu".source =
        pkgs.runCommand "plasma-applications.menu" { }
          ''
            cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
          '';

      # Mounting removable drives from the file manager.
      services.udisks2.enable = true;
    };

  flake.modules.homeManager.desktop =
    { pkgs, lib, ... }:
    let
      inherit (import ./_hyprland-lua.nix lib) bind bindWith exec;
      # Mumble's PipeWire backend gets SIGKILLed within a second: one of its
      # real-time audio threads runs past the 200ms RLIMIT_RTTIME that
      # PipeWire sets. Its PulseAudio backend, served by pipewire-pulse,
      # works.
      mumble = pkgs.mumble.override { pipewireSupport = false; };
      mumbleRpc = action: exec "${lib.getExe' mumble "mumble"} rpc ${action}";
      handle = app: types: lib.genAttrs types (_: app);
      textTypes = [
        "application/json"
        "application/toml"
        "application/x-shellscript"
        "application/x-yaml"
        "application/xml"
        "text/markdown"
        "text/plain"
        "text/x-nix"
        "text/x-python"
      ];
    in
    {
      home.packages = [
        mumble
        pkgs.loupe
        pkgs.pwvucontrol
      ];

      programs.mpv.enable = true;

      # Helix's own entry asks for a terminal, which xdg-open doesn't start
      # outside of a desktop environment, so open files in Ghostty directly.
      xdg.desktopEntries.helix-ghostty = {
        name = "Helix";
        exec = "ghostty -e hx %F";
        icon = "helix";
        noDisplay = true;
        mimeType = textTypes;
      };

      # Push-to-talk on the mouse's forward button. Wayland doesn't let
      # Mumble see input sent to other windows, so Hyprland drives it.
      wayland.windowManager.hyprland.settings.bind = [
        (bind "mouse:276" (mumbleRpc "starttalking"))
        (bindWith { release = true; } "mouse:276" (mumbleRpc "stoptalking"))
      ];

      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          # Follows the system light/dark preference.
          theme = "light:Catppuccin Latte,dark:Catppuccin Mocha";
          font-family = "Berkeley Mono";
          background-opacity = 0.9;
          background-blur = true;
          window-padding-x = 8;
          window-padding-y = 8;
          window-padding-balance = true;
        };
      };

      programs.vicinae = {
        enable = true;
        systemd.enable = true;
        settings = {
          theme = {
            dark.name = "catppuccin-mocha";
            light.name = "catppuccin-latte";
          };
          # Translucent so the compositor blur shows through.
          launcher_window.opacity = 0.9;
          # Launch apps in their own systemd scopes under UWSM, rather than
          # inside vicinae's service, where restarting vicinae would kill them.
          providers.applications.preferences.launchPrefix = "uwsm app --";
        };
      };

      programs.firefox = {
        enable = true;
        profiles.default = { };
      };

      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        settings.mgr = {
          sort_by = "natural";
          sort_translit = true;
          linemode = "size_and_mtime";
          show_symlink = true;
        };
        flavors =
          let
            flavors = pkgs.fetchFromGitHub {
              owner = "yazi-rs";
              repo = "flavors";
              rev = "1183892c904f7f0efdf4473e856ed308b7bea98d";
              hash = "sha256-E1OUF1+mT0V3crVxkewG2Y7hRu8fO+0oRl6NlINmw+o=";
            };
          in
          {
            catppuccin-mocha = "${flavors}/catppuccin-mocha.yazi";
            catppuccin-latte = "${flavors}/catppuccin-latte.yazi";
          };
        # Picked by the terminal's background color.
        theme.flavor = {
          dark = "catppuccin-mocha";
          light = "catppuccin-latte";
        };
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.mkMerge [
          { "inode/directory" = "org.kde.dolphin.desktop"; }
          (handle "firefox.desktop" [
            "application/pdf"
            "application/xhtml+xml"
            "text/html"
            "x-scheme-handler/about"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
          ])
          (handle "org.gnome.Loupe.desktop" [
            "image/avif"
            "image/bmp"
            "image/gif"
            "image/heic"
            "image/jpeg"
            "image/jxl"
            "image/png"
            "image/svg+xml"
            "image/tiff"
            "image/webp"
          ])
          (handle "mpv.desktop" [
            "audio/aac"
            "audio/flac"
            "audio/mp4"
            "audio/mpeg"
            "audio/ogg"
            "audio/opus"
            "audio/wav"
            "audio/x-wav"
            "video/mp4"
            "video/mpeg"
            "video/ogg"
            "video/quicktime"
            "video/webm"
            "video/x-matroska"
            "video/x-msvideo"
          ])
          (handle "org.kde.ark.desktop" [
            "application/gzip"
            "application/vnd.rar"
            "application/x-7z-compressed"
            "application/x-bzip2-compressed-tar"
            "application/x-compressed-tar"
            "application/x-tar"
            "application/x-xz-compressed-tar"
            "application/zip"
            "application/zstd"
          ])
          (handle "helix-ghostty.desktop" textTypes)
        ];
      };
    };
}
