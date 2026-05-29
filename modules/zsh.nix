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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = ''
      autoload -Uz compinit
      compinit -C
    '';
    autosuggestion.enable = true;

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
