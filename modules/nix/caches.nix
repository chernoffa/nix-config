let
  caches = {
    nix.settings.extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    nix.settings.extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
in
{
  flake.modules.nixos.base = caches;
  flake.modules.darwin.base = caches;
}
