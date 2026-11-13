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
      nvidia
      steam
      windows-dual-boot
      ./_hardware-configuration.nix
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "keter";
    networking.networkmanager.enable = true;

    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";

    users.users.achernoff.extraGroups = [ "networkmanager" ];

    # Windows C: drive. Matched by UUID since the NVMe names swap between
    # boots. ntfs3 refuses to mount it while Windows is hibernated (Fast
    # Startup), so nofail keeps that from blocking boot.
    fileSystems."/mnt/windows" = {
      device = "/dev/disk/by-uuid/EA2E71222E70E949";
      fsType = "ntfs3";
      options = [
        "nofail"
        "uid=1000"
        "gid=100"
        "windows_names"
      ];
    };

    hardware.bluetooth.enable = true;
    zramSwap.enable = true;
    nix.optimise.automatic = true;

    programs.nh = {
      enable = true;
      flake = "/home/achernoff/dev/nix-config";
    };

    # Both monitors at their highest refresh rate (144 Hz), PG279Q on the left.
    # Matched by description so they keep their places if the ports swap.
    home-manager.users.achernoff.wayland.windowManager.hyprland.settings.monitor = [
      {
        output = "desc:Ancor Communications Inc ROG PG279Q #ASMmWUg99+jd";
        mode = "highrr";
        position = "0x0";
        scale = 1;
      }
      {
        output = "desc:ASUSTek COMPUTER INC VG27AQ1A LALMQS233574";
        mode = "highrr";
        position = "2560x0";
        scale = 1;
      }
    ];

    home-manager.users.achernoff.home.stateVersion = "26.05";
    # Keep in sync with the value `nixos-generate-config` writes on install.
    system.stateVersion = "26.05";
  };
}
