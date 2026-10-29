{ config, ... }:

# The other files in this directory add to these two modules.
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    config.flake.modules.homeManager.desktop
  ];
}
