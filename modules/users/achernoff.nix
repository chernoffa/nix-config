{
  # The macOS account, which predates `me.username`.
  flake.modules.darwin.base = {
    users.users.achernoff.home = "/Users/achernoff";
    home-manager.users.achernoff = { };
    system.primaryUser = "achernoff";
  };
}
