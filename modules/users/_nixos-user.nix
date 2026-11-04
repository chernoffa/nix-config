# A NixOS account, shared by the user modules.
name:
{ pkgs, ... }:
{
  users.users.${name} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.${name} = { };
}
