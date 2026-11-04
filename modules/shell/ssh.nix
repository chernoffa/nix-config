{
  flake.modules.homeManager.base =
    { pkgs, lib, ... }:

    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            AddKeysToAgent = "yes";
          };
        };
      };

      services.ssh-agent.enable = lib.mkDefault pkgs.stdenv.isLinux;
    };
}
