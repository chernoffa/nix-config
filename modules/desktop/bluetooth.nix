{
  # Blueman's applet is the BlueZ agent that approves pairing and connection
  # requests; without one, bluetoothd rejects devices that aren't trusted.
  flake.modules.nixos.desktop =
    { config, ... }:
    {
      services.blueman.enable = config.hardware.bluetooth.enable;
    };

  flake.modules.homeManager.desktop =
    { osConfig, ... }:
    {
      services.blueman-applet.enable = osConfig.hardware.bluetooth.enable;
    };
}
