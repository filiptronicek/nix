# My Nix config

I store my config in `~/.config/nix/`. Because of that, it can be rebuilt like so:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#mbp
```

## Limitations

- Because of security limitations on macOS, we can't set Privacy and Security preferences.
- Because of more macOS weirdness, we can't set the Screen Saver
