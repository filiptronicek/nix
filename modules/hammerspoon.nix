{...}: {
  home.file.".hammerspoon/init.lua".source = ./hammerspoon.lua;

  launchd.agents.hammerspoon = {
    enable = true;
    config = {
      ProgramArguments = ["/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
