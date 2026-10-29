{ config, ... }:

let
  inherit (config.me) username;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        shell = pkgs.zsh;
      };

      home-manager.users.${username}.imports = [ config.flake.modules.homeManager.alex ];
    };

  flake.modules.homeManager.alex = {
    home.username = username;
    programs.helix.defaultEditor = true;
  };
}
