{ pkgs, ... }:
{
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

      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };
}
