{
  perSystem =
    { pkgs, ... }:
    {
      packages.berkeley-mono = pkgs.callPackage ./_package.nix { };
    };
}
