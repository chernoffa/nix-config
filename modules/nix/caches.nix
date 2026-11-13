let
  caches = {
    nix.settings.extra-substituters = [
      "https://nix-community.cachix.org"
      "https://helix.cachix.org"
    ];
    nix.settings.extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };
in
{
  flake.modules.nixos.base = caches;
  flake.modules.darwin.base = caches;
}
