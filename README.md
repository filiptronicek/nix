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

## Hyper shortcuts

Karabiner maps Caps Lock to Control+Option+Shift+Command. Hammerspoon handles
the shortcuts from `modules/hammerspoon.lua`, installed by Home Manager into
`~/.hammerspoon/init.lua` and started at login by a LaunchAgent. Its menu bar
icon is hidden by the Lua configuration.

| Shortcut | Action |
| --- | --- |
| ⇪ C | Center the focused window on its current display without resizing |
| ⇪ M | Maximize the focused window (without entering full screen) |
| ⇪ N | Move the focused window to the next display |
| ⇪ I | Open System Settings |
| ⇪ L | Lock the computer |
| ⇪ R | Capture the previous area with CleanShot |

## Firefox extensions

`modules/firefox-extensions.nix` declares the extensions. Activation imports the
policies into `/Library/Preferences/org.mozilla.firefoxdeveloperedition.plist` and enables
`EnterprisePoliciesEnabled`. Firefox Developer Edition reads these macOS policies
on startup, including for new profiles on a fresh machine; no manual extension
installation or first launch before rebuilding is needed. Firefox downloads the
latest extensions from Mozilla Add-ons (and Zotero from its official site), so
internet access is required. Extensions can still be disabled in Firefox.

After rebuilding, fully quit and reopen Firefox. Check `about:policies` for active
`ExtensionSettings` and errors, then `about:addons` for installed extensions.
Policies live outside the app bundle so Firefox/Homebrew updates preserve them.
The old `/Library/Application Support/Mozilla/policies.json` location is unused
by Firefox on macOS.

If macOS blocks a full rebuild from updating apps, grant the terminal running
`darwin-rebuild` access in System Settings → Privacy & Security → App Management.


## Kagi Search Token

Firefox policies read Kagi token from macOS Keychain service `kagi-search-token`
during activation (no token file in this repo).

Set/update token once:

```sh
security add-generic-password -a "$USER" -s "kagi-search-token" -w "PASTE_TOKEN_HERE" -U
```

Then rebuild:

```sh
sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix#mbp
```
