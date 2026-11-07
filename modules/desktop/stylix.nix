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

        # This target patches GtkSourceView through an overlay, which forces
        # everything linking it (like wayle) to build from source. The Home
        # Manager target still installs the same style as a user file.
        targets.gtksourceview.enable = false;

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

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
