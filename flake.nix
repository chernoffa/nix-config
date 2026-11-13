{
  description = "My Nix Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # Unreleased helix for [theme] light/dark (not in 25.07.1). Its own nixpkgs
    # is kept so builds match helix.cachix.org.
    helix.url = "github:helix-editor/helix";
    optmem.url = "github:VictorTaelin/OptMem";
    optmem.flake = false;
    grumble.url = "git+https://github.com/chernoffa/grumble";
    grumble.inputs.nixpkgs.follows = "nixpkgs";
    grumble.inputs.home-manager.follows = "home-manager";
  };

  # Dendritic pattern: every file under ./modules is a flake-parts module.
  # Paths containing `/_` are ignored by import-tree.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
