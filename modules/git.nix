{
  config,
  pkgs,
  ...
}: let
  secretiveHome = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data";
  signingPublicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCzSS6bvUGlnY4JLBx0v9hIpxEcyYhjXHZCbfaQcgJtjL/Zm93kvHi2JFow2ohF52HGhQwTcxFSMB4IeXcwg7Mw=";
  secretiveSign = pkgs.writeShellScript "secretive-ssh-sign" ''
    export SSH_AUTH_SOCK="${secretiveHome}/socket.ssh"
    exec /usr/bin/ssh-keygen "$@"
  '';
in {
  home.file.".config/git/allowed_signers".text = ''
    filip@trnck.dev,filip.tronicek@seznam.cz ${signingPublicKey}
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Filip Troníček";
      user.email = "filip@trnck.dev";
      # Inline the public key to avoid macOS restrictions on Secretive's app container.
      user.signingkey = "key::${signingPublicKey}";

      init.defaultBranch = "main";

      pull.rebase = true;

      push.default = "simple";
      push.autoSetupRemote = true;
      push.followTags = true;

      fetch.prune = true;
      fetch.pruneTags = true;
      fetch.all = true;

      core.editor = "zed --wait";

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

      gpg.format = "ssh";
      gpg.ssh.program = "${secretiveSign}";
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
    };
  };
}
