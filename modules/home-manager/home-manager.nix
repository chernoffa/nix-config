{ inputs, config, ... }:

let
  homeManagerSettings = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ config.flake.modules.homeManager.base ];
  };
in
{
  flake.modules.nixos.base.imports = [
    inputs.home-manager.nixosModules.home-manager
    homeManagerSettings
  ];

  flake.modules.darwin.base.imports = [
    inputs.home-manager.darwinModules.home-manager
    homeManagerSettings
  ];

  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Sensible default for `home.homeDirectory`
      home.homeDirectory = lib.mkDefault "/${
        if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"
      }/${config.home.username}";

      # For macOS, $PATH must contain these.
      home.sessionPath = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [
        "/etc/profiles/per-user/$USER/bin" # To access home-manager binaries
        "/nix/var/nix/profiles/system/sw/bin" # To access nix-darwin binaries
        "/usr/local/bin" # Some macOS GUI programs install here
      ];
    };
}
