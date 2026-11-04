{ config, ... }:

{
  flake.modules.nixos.alex = import ./_nixos-user.nix config.me.username;
}
