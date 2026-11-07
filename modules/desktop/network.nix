{
  # A tray icon for NetworkManager, for picking Wi-Fi networks and opening the
  # connection editor.
  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      services.network-manager-applet.enable = osConfig.networking.networkmanager.enable;
      # Run nm-applet with --indicator, since Quickshell's tray only shows
      # StatusNotifierItems.
      xsession.preferStatusNotifierItems = true;
    };
}
