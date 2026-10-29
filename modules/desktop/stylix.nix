{ inputs, ... }:

{
  # Stylix also adds its Home Manager module to every user.
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        image = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
        };
      };
    };

  flake.modules.homeManager.desktop = {
    # Keep the theme set in helix.nix.
    stylix.targets.helix.enable = false;
  };
}
