{ inputs, config, ... }:

{
  flake.nixosConfigurations.nacon = inputs.nixpkgs.lib.nixosSystem {
    modules = [ config.flake.modules.nixos.nacon ];
  };

  flake.modules.nixos.nacon = {
    imports = with config.flake.modules.nixos; [
      base
      alex
      wsl
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "nacon";

    home-manager.users.${config.me.username}.home.stateVersion = "22.11";
    system.stateVersion = "22.05";
  };
}
