{
  description = "Filip's macOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";

    # Custom tap sources — pinned via flake.lock
    gitpod-tap = {
      url = "github:gitpod-io/homebrew-tap";
      flake = false;
    };
    xykong-tap = {
      url = "github:xykong/homebrew-tap";
      flake = false;
    };
    typewhisper-tap = {
      url = "github:typewhisper/homebrew-tap";
      flake = false;
    };
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
        defaultbrowser = "browser"; # this is what Arc is
        username = "filip";
        homeDirectory = "/Users/${vars.username}";
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
            pkgs.nixfmt
            pkgs.cmake
            pkgs.rustup
            pkgs.ruby

            # Cloud & Infrastructure
            pkgs.awscli2
            pkgs.google-cloud-sdk
            pkgs.turso-cli
            pkgs.cloudflared
            pkgs.atlas
            pkgs.golangci-lint

            # Languages & Runtime
            pkgs.python314
            pkgs.pipx
            pkgs.bun

            pkgs.texliveMedium

            # System & File Utilities
            pkgs.coreutils
            pkgs.wget
            pkgs.rclone
            pkgs.p7zip
            pkgs.dust
            pkgs.bottom
            pkgs.unixtools.watch
            pkgs.defaultbrowser
            pkgs.zoxide
            pkgs.bat
            pkgs.eza
            pkgs.zstd
            pkgs.upx

            # Data Processing & Formatting
            pkgs.jq
            pkgs.yq
            pkgs.pandoc
            pkgs.pv

            pkgs.ffmpeg
            pkgs.imagemagick
            pkgs.yt-dlp
            pkgs.shaka-packager

            pkgs.gnupg
            pkgs.knot-dns
            pkgs.nmap

            # Misc
            pkgs.fastfetch
            pkgs.lolcat

            # GUI Applications
            pkgs.git-credential-manager
            pkgs.audacity
            pkgs.qbittorrent
            pkgs.monitorcontrol
            pkgs.duti
          ];

          # Add activation script
          system.activationScripts.extraActivation.text = ''
                        # Set Arc as default browser.
                        # Arc must be launched at least once before it registers as an HTTP handler.
                        # On a fresh install, open Arc in the background so it can register, then retry.
                        if [ -d "/Applications/Arc.app" ]; then
                          if ! sudo -u ${vars.username} ${pkgs.defaultbrowser}/bin/defaultbrowser ${vars.defaultbrowser} 2>/dev/null; then
                            echo "Arc not yet registered as an HTTP handler — launching Arc to register it..."
                            sudo -u ${vars.username} open -a "Arc" 2>/dev/null || true
                            sleep 5
                            sudo -u ${vars.username} ${pkgs.defaultbrowser}/bin/defaultbrowser ${vars.defaultbrowser} || \
                              echo "Warning: Could not set Arc as default browser. Re-run 'sudo darwin-rebuild switch --flake ~/.config/nix#mbp' after Arc has launched."
                          fi
                        fi

                        # Handle MonitorControl login item as primary user
                        sudo -u ${vars.username} osascript <<EOF
                          tell application "System Events"
                            try
                              delete (every login item whose name is "MonitorControl")
                            end try
                            make login item at end with properties {path:"${pkgs.monitorcontrol}/Applications/MonitorControl.app", hidden:false}
                          end tell
            EOF

                        # Set rustup default (moved from activation script)
                        command -v rustup >/dev/null && rustup default stable

                        # Set default applications for file types
                        sudo -u ${vars.username} ${pkgs.duti}/bin/duti ${./duti-config.txt}
          '';

          environment.etc."pam.d/sudo_local".text = ''
            # sudo_local: local config file which survives system update and is included for sudo
            # uncomment following line to enable Touch ID for sudo
            auth       sufficient     pam_tid.so
          '';

          nixpkgs.config.allowUnfree = true;

          # Rest of your configuration remains the same...
          fonts.packages = [
            pkgs.lexend
          ];

          users.users.${vars.username} = {
            name = vars.username;
            home = vars.homeDirectory;
          };

          # Set primary user for homebrew and user-specific settings
          system.primaryUser = vars.username;

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
              "gnu-sed"
              "php"
              "gitpod-io/tap/ona"
            ];
            casks = [
              "figma"
              "loom"
              "raycast"
              "orbstack"
              "tailscale"
              "linear-linear"
              "1password"
              "github"
              "jetbrains-toolbox"

              "ukelele"
              "karabiner-elements"
              "stats"
              "shottr"
              "rustdesk"
              "wireshark-app"

              "xykong/tap/flux-markdown" # markdown rendering for QuickLook
              "hyperkey" # Caps Lock modifier for Super
              "typewhisper/tap/typewhisper" # STT

              "blender"
              "thunderbird"
              "zotero"
              "adobe-creative-cloud"
              "microsoft-openjdk@21"
              "omnissa-horizon-client"

              "vlc"
              "handbrake-app"
              "kodi"

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
              "telegram"

              "microsoft-powerpoint"
              "microsoft-word"

              "discord"
              "slack"
              "parsec"
              "obs"
              "meetingbar"
              "obsidian"
              "ollama"
              "veracrypt"
              "warp"

              "tor-browser"
              "arc"
              "librewolf"
              "firefox@developer-edition"
              "ungoogled-chromium"
              "zen"
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
            home-manager.users.${vars.username} =
              { pkgs, ... }:
              {
                home.stateVersion = "25.05";
                programs.git = {
                  enable = true;
                  settings = {
                    user.name = "Filip Troníček";
                    user.email = "filip.tronicek@seznam.cz";

                    init.defaultBranch = "main";

                    pull.rebase = true;

                    push.default = "simple";
                    push.autoSetupRemote = true;
                    push.followTags = true;

                    fetch.prune = true;
                    fetch.pruneTags = true;
                    fetch.all = true;

                    core.editor = "cursor --wait";

                    column.ui = "auto";
                    branch.sort = "committerdate";
                    tag.sort = "version:refname";

                    diff.algorithm = "histogram";
                    diff.colorMoved = "plain";
                    diff.mnemonicPrefix = true;
                    diff.renames = true;

                    rebase.autoSquash = true;
                    rebase.autoStash = true;
                    rebase.updateRefs = true;

                    rerere.enabled = true;
                    rerere.autoupdate = true;

                    help.autocorrect = "prompt";

                    commit.gpgSign = true;
                    commit.verbose = true;

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
                    update = "{ cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake ~/.config/nix#mbp } && brew update && brew upgrade";

                    ytmp3 = "yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s'";
                    ytvideo = "yt-dlp -f bestvideo+bestaudio --merge-output-format mp4 -o '%(title)s.%(ext)s'";

                    ona = "gitpod";

                    # GNU utils alternatives
                    cat = "bat";
                    ls = "eza";
                    ll = "eza -l";
                    la = "eza -la";
                    tree = "eza -T";
                  };

                  initContent = ''
                    # NVM initialization
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
                    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

                    # Install LTS Node.js if not already installed
                    [ ! -e "$NVM_DIR/versions/node" ] && nvm install --lts

                    export PATH="$PATH:$(go env GOPATH)/bin"
                    export PATH="$(gem env gemdir)/bin:$PATH"
                    export PATH="$HOME/.local/bin:$PATH"

                    eval "$(zoxide init zsh --cmd cd)"
                  '';
                };
              };

            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = vars.username;
              autoMigrate = true;
              taps = {
                "gitpod-io/homebrew-tap" = inputs.gitpod-tap;
                "xykong/homebrew-tap" = inputs.xykong-tap;
                "typewhisper/homebrew-tap" = inputs.typewhisper-tap;
              };
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations."mbp".pkgs;
    };
}
