{ inputs, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];
  perSystem =
    { self', pkgs, ... }:
    {
      formatter = pkgs.nixfmt;
      packages = {
      };
    };
}
