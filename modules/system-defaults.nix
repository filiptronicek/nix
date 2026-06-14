{...}: {
  system.defaults = {
    # ─── Dock ─────────────────────────────────────────────────────────
    dock.autohide = true;
    dock.autohide-delay = 0.0; # pop in instantly when pushed to edge
    dock.autohide-time-modifier = 0.2;
    dock.tilesize = 60;
    dock.mru-spaces = false; # don't reorder spaces by recency
    dock.show-recents = false;
    dock.persistent-apps = [
      "/System/Volumes/Data/Applications/Firefox Developer Edition.app"
      "/System/Volumes/Data/Applications/Thunderbird.app"
      "/System/Volumes/Data/Applications/Slack.app"
    ];

    # ─── Finder ───────────────────────────────────────────────────────
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.FXPreferredViewStyle = "Nlsv"; # list view
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder._FXSortFoldersFirst = true;
    finder.FXDefaultSearchScope = "SCcf"; # search current folder by default
    finder.FXEnableExtensionChangeWarning = false;
    CustomUserPreferences."com.apple.finder".NSUserKeyEquivalents = {
      Rename = builtins.fromJSON ''"\uf705"''; # F2
    };

    # ─── System Settings → Menu Bar ──────────────────────────────────
    controlcenter = {
      AirDrop = false;
      Bluetooth = false;
      Display = false;
      FocusModes = true;
      NowPlaying = false;
      Sound = true;
    };

    CustomUserPreferences."com.apple.controlcenter" = {
      "NSStatusItem Visible Battery" = false;
      "NSStatusItem Visible BentoBox" = true; # Control Center
      "NSStatusItem Visible MusicRecognition" = false;
      "NSStatusItem Visible Shortcuts" = false;
      "NSStatusItem Visible WiFi" = false;
      "NSStatusItem VisibleCC BentoBox-0" = true;
      "NSStatusItem VisibleCC Clock" = true;
    };

    # ─── Login window ─────────────────────────────────────────────────
    loginwindow.GuestEnabled = false;

    # ─── Screenshot ───────────────────────────────────────────────────
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = false;
      include-date = true;
    };

    # ─── Global keyboard / input ──────────────────────────────────────
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
    NSGlobalDomain.AppleSpacesSwitchOnActivate = true; # cmd-tab jumps to app's space
    NSGlobalDomain.KeyRepeat = 2; # faster than the System Settings slider allows
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

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
