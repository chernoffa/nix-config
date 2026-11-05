{
  flake.modules.nixos.desktop =
    { config, lib, ... }:
    {
      programs._1password.enable = true;
      # 1Password is the SSH agent; keep gnome-keyring's from claiming SSH_AUTH_SOCK.
      services.gnome.gcr-ssh-agent.enable = false;
      programs._1password-gui = {
        enable = true;
        # Users allowed to unlock with system auth and connect the `op` CLI.
        polkitPolicyOwners = lib.attrNames (
          lib.filterAttrs (_: user: user.isNormalUser) config.users.users
        );
      };
    };

  flake.modules.homeManager.desktop =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    let
      onePassword = lib.getExe osConfig.programs._1password-gui.package;
      agentSocket = "${config.home.homeDirectory}/.1password/agent.sock";
    in
    {
      # 1Password serves SSH keys instead of ssh-agent.
      services.ssh-agent.enable = false;
      programs.ssh.settings."*".IdentityAgent = agentSocket;
      home.sessionVariables.SSH_AUTH_SOCK = agentSocket;

      # Start in the tray so the SSH agent and browser extension are ready.
      systemd.user.services."1password" = {
        Unit = {
          Description = "1Password";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${onePassword} --silent";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      wayland.windowManager.hyprland.settings.bind = with import ./_hyprland-lua.nix lib; [
        (bind "SUPER + SHIFT + Space" (app "${onePassword} --quick-access"))
      ];
    };
}
