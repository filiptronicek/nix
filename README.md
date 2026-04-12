# My Nix config

I store my config in `~/.config/nix/`. Because of that, it can be rebuilt like so:

```sh
sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix#mbp
```

## Fresh Mac bootstrap

Before running the above, take care of a few prerequisites that can't be automated:

**1. Rosetta 2** (required for x86_64 Homebrew packages on Apple Silicon):
```sh
softwareupdate --install-rosetta --agree-to-license
```

**2. Xcode Command Line Tools** (required for Homebrew source builds):
```sh
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
softwareupdate -i "$(softwareupdate -l 2>/dev/null | awk -F'\*' '/\* Label: Command Line Tools/{print $2}' | sed 's/^ *//' | tail -1)"
rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
```

## Limitations

- Because of security limitations on macOS, we can't set Privacy and Security preferences.
- Because of more macOS weirdness, we can't set the Screen Saver
