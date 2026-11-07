{
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        # Community Proton build with extra game fixes; selectable per game.
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      # Performance tweaks on demand via the `gamemoderun %command%` launch option.
      programs.gamemode.enable = true;
      # Micro-compositor for games with fullscreen or scaling issues on Wayland.
      programs.gamescope.enable = true;
    };
}
