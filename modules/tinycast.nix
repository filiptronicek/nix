{config, ...}: let
  # Tinycast stores HotKeyBinding as JSON; Carbon Cmd=256, Shift=512, Control=4096.
  shortcut = keyCode: modifiers:
    builtins.toJSON {
      combo._0 = {
        carbonKeyCode = keyCode;
        carbonModifiers = modifiers;
      };
    };
in {
  system.defaults.CustomUserPreferences."com.tinycast.app" = {
    clipboardEnabled = true;
    "hotkey.command:search-emoji" = shortcut 14 768; # Cmd+Shift+E
    "hotkey.command:clipboard-history" = shortcut 8 4352; # Control+Cmd+C
    # No launcher shortcut: Raycast remains the primary launcher.
    "hotkey.togglePalette" = "";
  };

  # Keep clipboard collection running from login, reusing any existing instance.
  home-manager.users.${config.system.primaryUser}.launchd.agents.tinycast = {
    enable = true;
    config = {
      ProgramArguments = ["/usr/bin/open" "-g" "-a" "/Applications/Tinycast.app"];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
