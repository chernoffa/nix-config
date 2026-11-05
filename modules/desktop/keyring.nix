{
  # Secret Service for apps that store logins (browsers, Electron, CLIs).
  flake.modules.nixos.desktop = {
    services.gnome.gnome-keyring.enable = true;
    # Unlock the keyring with the login password.
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
