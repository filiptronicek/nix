{
  config,
  lib,
  pkgs,
  ...
}: let
  registry = "${config.home.homeDirectory}/Library/Application Support/obsidian/obsidian.json";
  seed = pkgs.writeText "obsidian.json" (builtins.toJSON {
    vaults.a7e640f039bd128c = {
      path = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Filip's notes";
      ts = 1792274400000;
      open = true;
    };
  });
in {
  # Seed once; Obsidian owns and updates this writable file afterward.
  home.activation.seedObsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e ${lib.escapeShellArg registry} ] && [ ! -L ${lib.escapeShellArg registry} ]; then
      run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg (builtins.dirOf registry)}
      (
        umask 077
        run ${pkgs.coreutils}/bin/cp --no-clobber --no-preserve=mode ${seed} ${lib.escapeShellArg registry}
      )
    fi
  '';
}
