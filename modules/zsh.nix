{pkgs, ...}: {
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
    autosuggestion.enable = true;

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
      path=("$HOME/.local/bin" $path "$ruby_gem_bin" "$go_bin")
      unset ruby_gem_bin go_bin
    '';
  };
}
