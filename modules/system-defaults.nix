{
  config,
  lib,
  pkgs,
  ...
}: let
  # Upstream restores the previous on/off state after changing the schedule,
  # which can override the automatic schedule with a manual "off".
  nightlight = pkgs.nightlight.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace src/lib.rs \
          --replace-fail 'let status = self.status()?;' '/* Let macOS apply the new schedule. */' \
          --replace-fail 'self.toggle(status)' 'Ok(())'
      '';
  });
  configureNightShift = pkgs.writeShellScript "configure-night-shift" ''
    set -e
    # Reset the mode to clear a manual override even if the schedule is unchanged.
    ${nightlight}/bin/nightlight schedule stop
    ${nightlight}/bin/nightlight schedule start
  '';
in {
  system.defaults = {
    # ─── Dock ─────────────────────────────────────────────────────────
    dock.autohide = true;
    dock.autohide-delay = 0.0; # pop in instantly when pushed to edge
    dock.autohide-time-modifier = 0.2;
    dock.tilesize = 60;
    dock.mru-spaces = false; # don't reorder spaces by recency
    dock.show-recents = false;
    dock.persistent-others = []; # no pinned folders/stacks, including Downloads
    dock.persistent-apps = [
      "/System/Volumes/Data/Applications/Firefox Developer Edition.app"
      "/System/Volumes/Data/Applications/Thunderbird.app"
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
      FocusModes = false;
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
    NSGlobalDomain."com.apple.keyboard.fnState" = true;
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
    CustomUserPreferences.NSGlobalDomain.NSGlassTintAmount = "0.6";

    # Use Stats for the battery menu bar item (the native item is hidden above).
    CustomUserPreferences."eu.exelban.Stats" = {
      CPU_state = false;
      GPU_state = false;
      RAM_state = false;
      Disk_state = false;
      Sensors_state = false;
      Network_state = false;
      Bluetooth_state = false;
      Clock_state = false;
      Battery_state = true;
      Battery_battery_additional = "innerPercentage";
      # Applies to outside text; Stats handles inside text separately.
      Battery_battery_hideAdditionalWhenFull = true;
    };

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

  # nix-darwin's "default" icon style is null, which means this key must
  # be absent rather than set to a value.
  system.activationScripts.userDefaults.text = lib.mkAfter ''
    # Restore macOS's automatic sunset-to-sunrise Night Shift schedule.
    # Requires Location Services for macOS to determine sunset and sunrise.
    launchctl asuser "$(id -u -- ${lib.escapeShellArg config.system.primaryUser})" \
      sudo --user=${lib.escapeShellArg config.system.primaryUser} -- \
      ${configureNightShift}

    defaults delete -g AppleIconAppearanceTheme 2>/dev/null || true

    # Free Cmd+Shift+3/4 for CleanShot via Karabiner. Merge only these
    # entries; preserve clipboard shortcuts (29/31), the toolbar (184),
    # and all other system shortcuts.
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add \
      28 '<dict><key>enabled</key><false/></dict>' \
      30 '<dict><key>enabled</key><false/></dict>'
  '';
}
