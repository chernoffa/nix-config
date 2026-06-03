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

  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux { enable = true; };
}
