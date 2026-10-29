{
  flake.modules.darwin.base = {
    security.pam.services.sudo_local.touchIdAuth = true;

    system.defaults = {
      dock = {
        autohide = true;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        # Automatic light and dark mode
        AppleInterfaceStyleSwitchesAutomatically = true;
        # Full keyboard control
        AppleKeyboardUIMode = 3;
      };

      # Disable AdLib
      CustomSystemPreferences."com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
        allowIdentifierForAdvertising = false;
        forceLimitAdTracking = true;
        personalizedAdsMigrated = false;
      };
    };
  };
}
