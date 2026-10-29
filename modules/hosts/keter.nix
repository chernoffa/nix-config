{ inputs, config, ... }:

{
  flake.nixosConfigurations.keter = inputs.nixpkgs.lib.nixosSystem {
    modules = [ config.flake.modules.nixos.keter ];
  };

  flake.modules.nixos.keter = {
    imports = with config.flake.modules.nixos; [
      base
      wsl
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "keter";

    home-manager.users.${config.me.username}.home.stateVersion = "23.11";
    system.stateVersion = "22.05";
  };
}
