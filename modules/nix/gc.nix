let
  gc = {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
    };
  };
in
{
  flake.modules.nixos.base = gc;

  # Opt-in: not imported by any configuration yet.
  flake.modules.homeManager.gc = gc;
}
