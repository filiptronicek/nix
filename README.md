# My Nix config

I store my config in `~/.config/nix/`. Because of that, it can be rebuilt like so:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#mbp
```

## Rust Tooling

This repository now includes a Rust CLI tool for managing the Nix configuration:

### Installation

```sh
cargo build --release
```

### Usage

```sh
# Validate the flake.nix file
cargo run -- validate

# List all packages in the configuration
cargo run -- packages list

# Update the system (dry run)
cargo run -- update --dry-run

# Update the system
cargo run -- update
```

### Features

- **Validate**: Check if the flake.nix file has proper structure
- **Package Management**: List packages defined in the configuration
- **System Updates**: Wrapper around darwin-rebuild with better error handling
- **Dry Run Support**: Test changes before applying them

## Limitations

- Because of security limitations on macOS, we can't set Privacy and Security preferences.
- Because of more macOS weirdness, we can't set the Screen Saver
- Package addition/removal through the CLI tool requires manual flake.nix editing for now
