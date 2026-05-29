{...}: {
  system.defaults = {
    dock.autohide = true;
    dock.tilesize = 60;
    dock.persistent-apps = [
      "/System/Volumes/Data/Applications/Firefox Developer Edition.app"
      "/System/Volumes/Data/Applications/Thunderbird.app"
      "/System/Volumes/Data/Applications/Slack.app"
    ];

    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    loginwindow.GuestEnabled = false;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;

    # Enabled keyboard input sources. CZX is the custom layout installed
    # to /Library/Keyboard Layouts/ via the activation script. May require
    # a logout/login for macOS to register changes.
    CustomUserPreferences."com.apple.HIToolbox".AppleEnabledInputSources = [
      {
        InputSourceKind = "Keyboard Layout";
        "KeyboardLayout ID" = 0;
        "KeyboardLayout Name" = "U.S.";
      }
      {
        InputSourceKind = "Keyboard Layout";
        "KeyboardLayout ID" = -9364;
        "KeyboardLayout Name" = "CZX";
      }
      {
        "Bundle ID" = "com.apple.CharacterPaletteIM";
        InputSourceKind = "Non Keyboard Input Method";
      }
      {
        "Bundle ID" = "com.apple.PressAndHold";
        InputSourceKind = "Non Keyboard Input Method";
      }
      {
        "Bundle ID" = "com.apple.inputmethod.ironwood";
        InputSourceKind = "Non Keyboard Input Method";
      }
    ];
  };
}
