{
  flake.modules.nixos.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      services.greetd = {
        # pond.nix turns this off for Pond's SDDM login screen.
        enable = lib.mkDefault true;
        # Keeps boot messages from drawing over the greeter.
        useTextGreeter = true;
        settings.default_session.command = lib.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--time"
          "--asterisks"
          "--remember"
          "--remember-session"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
      };
    };
}
