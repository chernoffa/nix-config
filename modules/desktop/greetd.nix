{
  # Noctalia's greeter under greetd, matching the shell's palette and
  # wallpaper. Noctalia's "Sync Now" can't change what's set here, since
  # greeter.toml takes precedence over what it syncs.
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings = {
          session.default = "Hyprland (uwsm-managed)";
          appearance = {
            scheme = "Noctalia";
            font_family = "Inter";
            wallpaper = {
              path = "${pkgs.noctalia}/share/noctalia/assets/noctalia-wallpaper.png";
              fill_mode = "crop";
            };
          };
          cursor.size = 24;
          keyboard.layout = "us";
        };
        cursorTheme = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
        };
      };
    };
}
