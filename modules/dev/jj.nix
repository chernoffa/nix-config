{
  flake.modules.homeManager.base = {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Alexander Chernoff";
          email = "alex@chernoff.xyz";
        };
        ui.diff-formatter = [
          "difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };
}
