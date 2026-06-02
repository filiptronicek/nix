{pkgs, ...}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # cached `nix develop` shells
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      search_mode = "fuzzy";
      style = "compact";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # adds Ctrl-R history + Ctrl-T file picker
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = false; # we set our own aliases below
    git = true;
    icons = "auto";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      command_timeout = 1000;

      format = "$username$hostname$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";
      right_format = "$status";

      username = {
        format = "[$user]($style)";
        style_user = "blue";
        style_root = "red bold";
        show_always = false;
      };

      hostname = {
        format = "[@$hostname]($style) ";
        style = "bright-black";
        ssh_only = true;
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        repo_root_format = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        style = "bright-black";
        repo_root_style = "blue bold";
        read_only = " ro";
        read_only_style = "red";
        truncation_length = 3;
        truncation_symbol = "../";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style = "green";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "yellow";
        conflicted = "=";
        ahead = ">$count";
        behind = "<$count";
        diverged = "<>$ahead_count/$behind_count";
        up_to_date = "";
        untracked = "?$count";
        stashed = "*$count";
        modified = "!$count";
        staged = "+$count";
        renamed = "r$count";
        deleted = "x$count";
      };

      nix_shell = {
        format = "[nix]($style) ";
        style = "blue";
        heuristic = true;
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bright-black";
        min_time = 2000;
      };

      status = {
        disabled = false;
        format = "[$status]($style)";
        style = "red";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](blue)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = ''
      autoload -Uz compinit
      compinit -C
    '';
    autosuggestion.enable = true;

    plugins = [
      {
        name = "zsh-shift-select";
        file = "zsh-shift-select.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "jirutka";
          repo = "zsh-shift-select";
          rev = "da460999b7d31aef0f0a82a3e749d70edf6f2ef9";
          hash = "sha256-ekA8acUgNT/t2SjSBGJs2Oko5EB7MvVUccC6uuTI/vc=";
        };
      }
    ];

    shellAliases = {
      gocov = "go test -cover ./...";
      # darwin-rebuild now handles brew update/upgrade (homebrew.onActivation)
      # and GC (nix.gc.automatic). Just flake update + switch + HM cleanup.
      update = "{ cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake ~/.config/nix#mbp } && home-manager expire-generations '-14 days'";

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
      ruby_gem_bin="''${GEM_HOME:-$HOME/.gem/ruby/${baseNameOf pkgs.ruby.gemPath}}/bin"
      go_bin="''${GOPATH:-$HOME/go}/bin"
      path=("$HOME/.local/bin" $path "$ruby_gem_bin" "$go_bin")
      unset ruby_gem_bin go_bin
    '';
  };
}
