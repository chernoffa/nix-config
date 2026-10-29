# Opt-in: not imported by any configuration yet.
{
  flake.modules.homeManager.zellij = {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
