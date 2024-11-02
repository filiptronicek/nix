# My Nix config

I store my config in `~/.config/nix/`. Because of that, it can be rebuilt like so:

```sh
darwin-rebuild switch --flake ~/.config/nix#mbp
```
