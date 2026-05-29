{
  description = "Filip's macOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
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

    dotfiles = {
      url = "github:filiptronicek/dotfiles";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-stable,
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
        let
          stablePkgs = import nixpkgs-stable {
            inherit (pkgs.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          };
          wrangler = pkgs.wrangler.override {
            # wrangler 4.93.0 fails during tsup on the current default Node.
            nodejs = pkgs.nodejs_22;
          };
          clock-check = pkgs.rustPlatform.buildRustPackage {
            pname = "clock-check";
            version = "0.4.0";
            src = pkgs.fetchFromGitHub {
              owner = "filiptronicek";
              repo = "time-server";
              rev = "03ff54c8521dad45eb63ffd4c03b92e9e16f40d6";
              hash = "sha256-rxm2lPJTEkRTvXixnUe+j7DmUpS4fQXEQZYL4BiP88Y=";
            };
            cargoHash = "sha256-V4/H4aYgIT07fTvzBIR/opv5hkz3i4HwPRTvkzwJjKE=";
            cargoBuildFlags = [ "-p" "clock-check" ];
            cargoTestFlags = [ "-p" "clock-check" ];
            doCheck = false;
            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];
          };
        in
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.neovim
            pkgs.git
            pkgs.gh
            pkgs.home-manager
            pkgs.pre-commit
            pkgs.nixd
            pkgs.nixfmt
            pkgs.cmake
            pkgs.rustup
            pkgs.ruby
            clock-check

            # Cloud & Infrastructure
            pkgs.awscli2
            pkgs.google-cloud-sdk
            pkgs.turso-cli
            pkgs.cloudflared
            pkgs.atlas
            wrangler

            # Languages & Runtime
            pkgs.nodejs
            pkgs.python314
            stablePkgs.pipx
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
            pkgs.mkvtoolnix

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
            pkgs.ghostty-bin
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
                        sudo -u ${vars.username} osascript >/dev/null <<EOF
                          tell application "System Events"
                            try
                              delete (every login item whose name is "MonitorControl")
                            end try
                            make login item at end with properties {name:"MonitorControl", path:"${pkgs.monitorcontrol}/Applications/MonitorControl.app", hidden:false}
                          end tell
            EOF

                        # Set rustup default (moved from activation script)
                        command -v rustup >/dev/null && rustup default stable

                        # Use Cloudflare NTP for system time
                        systemsetup -setnetworktimeserver time.cloudflare.com >/dev/null 2>&1 || \
                          echo "Warning: Could not set network time server. Check macOS Date & Time settings." >&2
                        systemsetup -setusingnetworktime on >/dev/null 2>&1 || \
                          echo "Warning: Could not enable network time. Check macOS Date & Time settings." >&2

                        # Install custom keyboard layouts system-wide.
                        # After first install, add "CZX" via System Settings → Keyboard → Input Sources.
                        install -d -m 755 "/Library/Keyboard Layouts"
                        install -m 644 ${inputs.dotfiles}/code.ty.keylayout "/Library/Keyboard Layouts/code.ty.keylayout"

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
              "pnpm"
              "handbrake"
              "paperjam"
              "gnu-sed"
              "php"
              "gitpod-io/tap/ona"
              "rust-analyzer"
            ];
            goPackages = [
              "github.com/filiptronicek/bruh"
              "github.com/mattn/bsky"
              "github.com/bufbuild/buf/cmd/buf"
              "github.com/go-delve/delve/cmd/dlv"
              "github.com/tantalor93/dnspyre/v2"
              "github.com/golangci/golangci-lint/cmd/golangci-lint"
              "golang.org/x/tools/gopls"
              "github.com/mitranim/gow"
              "github.com/fullstorydev/grpcurl/cmd/grpcurl"
              "github.com/interclip/iclip"
              "github.com/tdewolff/minify/v2/cmd/minify"
              "go.uber.org/mock/mockgen"
              "github.com/csweichel/oci-tool"
              "connectrpc.com/connect/cmd/protoc-gen-connect-go"
              "github.com/sudorandom/protoc-gen-connect-openapi"
              "google.golang.org/protobuf/cmd/protoc-gen-go"
              "google.golang.org/grpc/cmd/protoc-gen-go-grpc"
              "github.com/bufbuild/protoschema-plugins/cmd/protoc-gen-jsonschema"
              "github.com/gitpod-io/gitpod-next/api/go/tools/logfields/protoc-logfields"
              "github.com/boyter/scc/v3"
              "honnef.co/go/tools/cmd/staticcheck"
            ];
            casks = [
              "figma"
              "loom"
              "raycast"
              "orbstack"
              "tailscale-app"
              "linear"
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
              "cyberduck"

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

              "codex"

              "utm"
              "signal"
              "telegram"

              "microsoft-powerpoint"
              "microsoft-word"

              "discord"
              "slack"
              "parsec"
              "obs"
              "obsidian"
              "ollama-app"
              "macfuse"
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

            # Enabled keyboard input sources. CZX is the custom layout installed
            # to /Library/Keyboard Layouts/ via the activation script above.
            # May require a logout/login for macOS to register changes.
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
                  options = [
                    "--cmd"
                    "cd"
                  ];
                };

                programs.zsh = {
                  enable = true;
                  enableCompletion = true;
                  completionInit = ''
                    autoload -Uz compinit
                    compinit -C
                  '';
                  autosuggestion = {
                    enable = true;
                  };

                  shellAliases = {
                    gocov = "go test -cover ./...";
                    update = "{ cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake ~/.config/nix#mbp } && brew update && brew upgrade && home-manager expire-generations '-14 days' && nix-collect-garbage --delete-older-than 14d && sudo nix-collect-garbage --delete-older-than 14d";

                    ytmp3 = "yt-dlp --ffmpeg-location ${pkgs.ffmpeg}/bin -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s'";
                    ytvideo = "yt-dlp --ffmpeg-location ${pkgs.ffmpeg}/bin -f bestvideo+bestaudio --merge-output-format mp4 -o '%(title)s.%(ext)s'";

                    # GNU utils alternatives
                    cat = "bat";
                    ls = "eza";
                    ll = "eza -l";
                    la = "eza -la";
                    tree = "eza -T";
                  };

                  initContent = ''
                    ruby_gem_bin="''${GEM_HOME:-$HOME/.gem/ruby/${builtins.baseNameOf pkgs.ruby.gemPath}}/bin"
                    go_bin="''${GOPATH:-$HOME/go}/bin"
                    path=("$HOME/.local/bin" "$ruby_gem_bin" $path "$go_bin")
                    unset ruby_gem_bin go_bin
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
