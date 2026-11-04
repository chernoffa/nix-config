{ inputs, config, ... }:

{
  flake.nixosConfigurations.keter = inputs.nixpkgs.lib.nixosSystem {
    modules = [ config.flake.modules.nixos.keter ];
  };

  flake.modules.nixos.keter = {
    imports = with config.flake.modules.nixos; [
      base
      achernoff
      desktop
      ./_hardware-configuration.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "keter";
    networking.networkmanager.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    users.users.achernoff.extraGroups = [ "networkmanager" ];

    services.openssh.enable = true;

    home-manager.users.achernoff.home.stateVersion = "26.11";
    # Keep in sync with the value `nixos-generate-config` writes on install.
    system.stateVersion = "26.11";
  };
}
