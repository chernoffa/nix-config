{ inputs, ... }:

{
  # Grumble, the Mumble client from ~/dev/proj/grumble. Its module also binds
  # global push-to-talk in the Hyprland config.
  flake.modules.homeManager.desktop = {
    imports = [ inputs.grumble.homeManagerModules.default ];
    programs.grumble = {
      enable = true;
      # The mouse's forward side button.
      pushToTalk.key = "mouse:276";
    };
  };
}
