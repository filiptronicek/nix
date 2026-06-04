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

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nixpkgs-stable,
    nix-homebrew,
    home-manager,
    ...
  }: let
    vars = {
      defaultbrowser = "zen";
      username = "filip";
      homeDirectory = "/Users/${vars.username}";
    };
    configuration = {pkgs, ...}: let
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
        cargoBuildFlags = [
          "-p"
          "clock-check"
        ];
        cargoTestFlags = [
          "-p"
          "clock-check"
        ];
        doCheck = false;
        nativeBuildInputs = [pkgs.pkg-config];
        buildInputs = [pkgs.openssl];
      };
    in {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.neovim
        pkgs.git
        pkgs.gh
        pkgs.home-manager
        pkgs.pre-commit
        pkgs.nixd
        pkgs.alejandra
        pkgs.cmake
        pkgs.rustup
        pkgs.ruby
        pkgs.fastlane
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
        pkgs.deno

        pkgs.texliveMedium

        # System & File Utilities
        pkgs.coreutils
        pkgs.wget
        pkgs.websocat
        pkgs.curl
        pkgs.rclone
        pkgs.p7zip
        pkgs.dust
        pkgs.bottom
        pkgs.unixtools.watch
        pkgs.defaultbrowser
        pkgs.zstd
        pkgs.upx
        pkgs.sl

        # Data Processing & Formatting
        pkgs.jq
        pkgs.yq
        pkgs.pandoc
        pkgs.pv

        pkgs.ffmpeg
        pkgs.imagemagick
        pkgs.exiftool
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
                    # Set Zen as default browser.
                    if [ -d "/Applications/Zen.app" ]; then
                      sudo -u ${vars.username} ${pkgs.defaultbrowser}/bin/defaultbrowser ${vars.defaultbrowser} || \
                        echo "Warning: Could not set Zen as default browser."
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

      security.pam.services.sudo_local = {
        touchIdAuth = true;
        watchIdAuth = true; # Apple Watch sudo
        reattach = true; # works inside tmux/screen
      };

      nix.gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      nix.optimise.automatic = true;
      nix.linux-builder.enable = true;

      nixpkgs.config.allowUnfree = true;

      # Rest of your configuration remains the same...
      fonts.packages = [
        pkgs.lexend
        pkgs.jetbrains-mono
      ];

      users.users.${vars.username} = {
        name = vars.username;
        home = vars.homeDirectory;
      };

      # Set primary user for homebrew and user-specific settings
      system.primaryUser = vars.username;

      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mbp
    darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        ./modules/firefox-extensions.nix
        ./modules/homebrew.nix
        ./modules/karabiner.nix
        ./modules/system-defaults.nix
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        {
          environment.variables = {
            EDITOR = "zed --wait";
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.users.${vars.username} = {pkgs, ...}: {
            imports = [
              ./modules/firefox.nix
              ./modules/git.nix
              ./modules/zsh.nix
              ./modules/ghostty.nix
              ./modules/zed.nix
            ];

            home.stateVersion = "26.05";
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
