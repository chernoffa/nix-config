{
  # The macOS account, which predates `me.username`.
  flake.modules.darwin.base = {
    users.users.achernoff.home = "/Users/achernoff";
    home-manager.users.achernoff = { };
    system.primaryUser = "achernoff";
  };

  flake.modules.nixos.achernoff =
    { pkgs, ... }:
    {
      users.users.achernoff = {
        isNormalUser = true;
        shell = pkgs.zsh;
      };

      home-manager.users.achernoff = {
        home.username = "achernoff";
        programs.helix.defaultEditor = true;
      };
    };
}
