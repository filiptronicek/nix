{
  description = "Filip's macOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      home-manager,
      ...
    }:
    let
      vars = {
        defaultbrowser = "browser"; # the registered name for Arc https://github.com/kerma/defaultbrowser/issues/27
      };
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.neovim
            pkgs.git
            pkgs.gh
            pkgs.pre-commit
            pkgs.nixd
            pkgs.nixfmt-rfc-style
            pkgs.cmake
            pkgs.rustup

            # Cloud & Infrastructure
            pkgs.awscli2
            pkgs.google-cloud-sdk
            pkgs.turso-cli
            pkgs.cloudflared
            pkgs.atlas

            # Languages & Runtime
            pkgs.python314
            pkgs.pipx
            pkgs.bun

            # System & File Utilities
            pkgs.coreutils
            pkgs.tree
            pkgs.wget
            pkgs.rclone
            pkgs.p7zip
            pkgs.dust
            pkgs.bottom
            pkgs.unixtools.watch
            pkgs.defaultbrowser
            pkgs.zoxide

            # Data Processing & Formatting
            pkgs.jq
            pkgs.yq
            pkgs.pandoc
            pkgs.pv

            pkgs.ffmpeg
            pkgs.imagemagick
            pkgs.yt-dlp

            pkgs.gnupg
            pkgs.knot-dns

            # Misc
            pkgs.fastfetch
            pkgs.lolcat

            # GUI Applications
            pkgs.git-credential-manager
            pkgs.audacity
            pkgs.raycast
            pkgs.qbittorrent
            pkgs.warp-terminal
            pkgs.monitorcontrol
            pkgs.wireshark-qt
          ];

          # Add activation script for defaultbrowser
          system.activationScripts.postUserActivation.text = ''
            defaultbrowser ${vars.defaultbrowser};
            rustup default stable;

            # Handle MonitorControl login item
            osascript -e '
            tell application "System Events"
              try
                delete (every login item whose name is "MonitorControl")
              end try
              make login item at end with properties {path:"${pkgs.monitorcontrol}/Applications/MonitorControl.app", hidden:false}
            end tell'
          '';

          nixpkgs.config.allowUnfree = true;

          # Rest of your configuration remains the same...
          fonts.packages = [
            pkgs.lexend
          ];

          users.users.filip = {
            name = "filip";
            home = "/Users/filip";
          };

          homebrew = {
            enable = true;
            brews = [
              "bettercap"
              "gnupg"
              "go"
              "nvm"
              "pnpm"
              "handbrake"
              "paperjam"
            ];
            casks = [
              "figma"
              "loom"
              "ukelele"
              "amie"
              "orbstack"
              "linear-linear"
              "shottr"
              "tailscale"
              "stats"
              "karabiner-elements"
              "vlc"
              "rustdesk"
              "handbrake"
              "1password"
              "blender"
              "thunderbird"
              "zotero"
              "github"
              "jetbrains-toolbox"
              "adobe-creative-cloud"

              "swiftdefaultappsprefpane"
              "meetingbar"

              "lunar-client"
              "whisky"
              "steam"

              "zed"
              "visual-studio-code"
              "vscodium"
              "cursor"

              "utm"
              "signal"
              "microsoft-powerpoint"
              "discord"
              "slack"
              "parsec"
              "obs"
              "meetingbar"
              "obsidian"
              "ollama"

              "tor-browser"
              "arc"
              "firefox"
              "firefox@nightly"
              "firefox@developer-edition"
              "eloston-chromium"
              "zen-browser"
            ];

            onActivation.cleanup = "zap";
          };

          system.defaults = {
            dock.autohide = true;
            dock.tilesize = 60;
            dock.persistent-apps = [
              "/System/Volumes/Data/Applications/Firefox Developer Edition.app"
              "/System/Volumes/Data/Applications/Thunderbird.app"
              "/System/Volumes/Data/Applications/Slack.app"
              "/System/Volumes/Data/Applications/Discord.app"
            ];

            finder.AppleShowAllExtensions = true;
            finder.AppleShowAllFiles = true;
            loginwindow.GuestEnabled = false;
            NSGlobalDomain."com.apple.swipescrolldirection" = false;
            NSGlobalDomain.AppleICUForce24HourTime = true;
            NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
          };

          nix.settings.experimental-features = "nix-command flakes";
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 5;
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mbp
      darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            environment.variables = {
              EDITOR = "cursor --wait";
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.filip =
              { pkgs, ... }:
              {
                home.stateVersion = "24.05";
                programs.git = {
                  enable = true;
                  userName = "Filip Troníček";
                  userEmail = "filip.tronicek@seznam.cz";
                  extraConfig = {
                    init.defaultBranch = "main";
                    pull.rebase = true;
                    core.editor = "cursor --wait";

                    commit.gpgSign = true;
                    gpg.program = "${pkgs.gnupg}/bin/gpg";
                  };
                };
                programs.zoxide = {
                  enable = true;
                  enableZshIntegration = true;
                };

                programs.zsh = {
                  enable = true;
                  enableCompletion = true;
                  autosuggestion = {
                    enable = true;
                  };

                  shellAliases = {
                    gocov = "go test -cover ./...";
                    update = "{ cd ~/.config/nix && nix flake update && darwin-rebuild switch --flake ~/.config/nix#mbp } && brew update && brew upgrade";

                    ytmp3 = "yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s'";
                    ytvideo = "yt-dlp -f bestvideo+bestaudio --merge-output-format mov -o '%(title)s.%(ext)s'";
                  };

                  initExtra = ''
                    # NVM initialization
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
                    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

                    # Install LTS Node.js if not already installed
                    [ ! -e "$NVM_DIR/versions/node" ] && nvm install --lts

                    eval "$(zoxide init zsh --cmd cd)"
                  '';
                };
              };

            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "filip";
              autoMigrate = true;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations."mbp".pkgs;
    };
}
