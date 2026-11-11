{ inputs, config, ... }:

{
  flake.darwinConfigurations.tzadkiel = inputs.nix-darwin.lib.darwinSystem {
    modules = [ config.flake.modules.darwin.tzadkiel ];
  };

  flake.modules.darwin.tzadkiel = {
    imports = [ config.flake.modules.darwin.base ];

    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "tzadkiel";

    programs.nh = {
      enable = true;
      flake = "/Users/achernoff/nix-config";
    };

    home-manager.users.achernoff.home.stateVersion = "24.11";
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    system.stateVersion = 5;
  };
}
