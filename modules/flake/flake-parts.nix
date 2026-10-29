{ inputs, config, ... }:

{
  imports = [
    # Provides `flake.modules.<class>.<name>` for deferred lower-level modules.
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  perSystem =
    {
      lib,
      system,
      pkgs,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = lib.attrValues config.flake.overlays;
        config.allowUnfree = true;
      };

      formatter = pkgs.nixfmt;
    };
}
