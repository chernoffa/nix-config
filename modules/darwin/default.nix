{ flake, ... }:

let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      # For home-manager to work
      users.users."achernoff" = {
        home = "/Users/achernoff";
      };
      home-manager.users."achernoff" = { };
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.jj
      ];
    }
    # Import the shared nix/caches modules by path rather than via
    # `self.nixosModules.common`, which nixos-unified tags with
    # `_class = "nixos"` and so cannot be imported into a darwin evaluation.
    (self + /modules/nixos/shared/nix.nix)
    (self + /modules/nixos/shared/caches.nix)
  ];

  # Disable AdLib
  system.defaults.CustomSystemPreferences."com.apple.AdLib" = {
    allowApplePersonalizedAdvertising = false;
    allowIdentifierForAdvertising = false;
    forceLimitAdTracking = true;
    personalizedAdsMigrated = false;
  };
}
