{ inputs, config, ... }:

{
  flake.modules.nixos.wsl =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-wsl.nixosModules.default ];

      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        defaultUser = config.me.username;
        startMenuLaunchers = true;
      };

      # services.displayManager.sddm.enable = true;
      # services.displayManager.sddm.wayland.enable = true;
      services.xserver.enable = true;

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        config.common.default = "*";
        extraPortals = [
          pkgs.xdg-desktop-portal-wlr
        ];
      };

      home-manager.sharedModules = [ config.flake.modules.homeManager.wsl ];
    };

  flake.modules.homeManager.wsl =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.wsl-open
        pkgs.xdg-utils.out
      ];

      home.sessionVariables = {
        BROWSER = "${pkgs.wsl-open}/bin/wsl-open";
      };
    };
}
