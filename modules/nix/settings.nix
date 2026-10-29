{ inputs, config, ... }:

let
  nixSettings =
    { pkgs, lib, ... }:
    {
      nixpkgs = {
        config = {
          allowBroken = true;
          allowUnfree = true;
        };
        overlays = lib.attrValues config.flake.overlays;
      };

      nix = {
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # Enables `nix-shell -p`
        registry.nixpkgs.flake = inputs.nixpkgs; # Make `nix shell` use pinned nixpkgs

        settings = {
          max-jobs = "auto";
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          extra-platforms = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "aarch64-darwin x86_64-darwin";
        };
      };
    };
in
{
  flake.modules.nixos.base = {
    imports = [ nixSettings ];
    nix.settings.trusted-users = [ "@wheel" ];
  };

  flake.modules.darwin.base =
    { config, ... }:
    {
      imports = [ nixSettings ];
      nix.settings.trusted-users = [ config.system.primaryUser ];
    };
}
