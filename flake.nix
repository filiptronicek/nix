{
  description = "Filip's macOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
        pkgs.gh
        pkgs.git
        pkgs.wget
        pkgs.yt-dlp
        pkgs.rclone
        pkgs.lolcat
        pkgs.awscli2
        pkgs.bun
        pkgs.pre-commit
        pkgs.pandoc
        pkgs.imagemagick
        pkgs.fastfetch
        pkgs.coreutils
        pkgs.ffmpeg
        pkgs.zoxide # todo: do the whole dance with zoxide
        pkgs.jq
        pkgs.yq
        pkgs.gnupg
        pkgs.unixtools.watch
        pkgs.nixd

        # GUIs
        pkgs.git-credential-manager
        pkgs.arc-browser
        pkgs.audacity
        pkgs.raycast
        pkgs.qbittorrent
        pkgs.obsidian
        pkgs.warp-terminal
        pkgs.monitorcontrol
        pkgs.wireshark-qt

        pkgs.knot-dns
        ];

      nixpkgs.config.allowUnfree = true;

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
          "handbrake"
        ];
        casks = [
          "firefox"
          "firefox@nightly"
          "figma"
          "safari-technology-preview"
          "eloston-chromium"
          "loom"
          "ukelele"
          "amie"
          "orbstack"
          "linear-linear"
          "nvidia-geforce-now"
          "shottr"
          "tailscale"
          "cursor"
          "stats"
          "karabiner-elements"
          "vlc"
          "rustdesk"
          "handbrake"
          "1password"
          "blender"
          "thunderbird"
          "lunar-client"
          "steam"
          "zotero"
          "github"
          "jetbrains-toolbox"
          "adobe-creative-cloud"
          "zed"
          "visual-studio-code"
          "vscodium"
          "utm"
          "signal"
          "microsoft-powerpoint"
          "discord"
          "slack"
          "parsec"
        ];

        onActivation.cleanup = "zap";
      };

      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [
          # "/System/Library/CoreServices/Finder.app" this is always there
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

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.filip = { pkgs, ... }: {
            home.stateVersion = "24.05";
            programs.git = {
              enable = true;
              userName = "Filip Troníček";
              userEmail = "filip.tronicek@seznam.cz";
              extraConfig = {
                init.defaultBranch = "main";
                pull.rebase = true;
                core.editor = "code --wait";

                commit.gpgSign = true;
                gpg.program = "${pkgs.gnupg}/bin/gpg";
              };
            };
            programs.zoxide = {
              enable = true;
              enableZshIntegration = true;
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

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mbp".pkgs;
  };
}
