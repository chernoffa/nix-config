{
  flake.overlays.berkeley-mono = final: _: {
    berkeley-mono = final.callPackage ./_package.nix { };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.berkeley-mono = pkgs.berkeley-mono;
    };
}
