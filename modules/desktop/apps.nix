{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      # Dolphin outside of Plasma: thumbnails, network mounts, and SVG icons.
      environment.systemPackages = [
        pkgs.kdePackages.dolphin
        pkgs.kdePackages.kio-extras
        pkgs.kdePackages.kio-fuse
        pkgs.kdePackages.qtsvg
      ];

      # Without a Plasma menu file, Dolphin's "Open With" list is empty.
      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      # Mounting removable drives from the file manager.
      services.udisks2.enable = true;
    };

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pwvucontrol ];

      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.fuzzel = {
        enable = true;
        settings.main = {
          terminal = "ghostty -e";
          launch-prefix = "uwsm app --";
        };
      };

      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = "org.kde.dolphin.desktop";
      };
    };
}
