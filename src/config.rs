use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::process::Command;
use tokio::process::Command as AsyncCommand;

#[derive(Debug, Serialize, Deserialize)]
pub struct Variables {
    pub defaultbrowser: String,
    pub username: String,
    pub home_directory: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SystemPackage {
    pub name: String,
    pub version: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Configuration {
    pub vars: Variables,
    pub system_packages: Vec<SystemPackage>,
    pub homebrew_brews: Vec<String>,
    pub homebrew_casks: Vec<String>,
    pub system_defaults: HashMap<String, serde_json::Value>,
}

impl Default for Configuration {
    fn default() -> Self {
        Self {
            vars: Variables {
                defaultbrowser: "browser".to_string(),
                username: "filip".to_string(),
                home_directory: "/Users/filip".to_string(),
            },
            system_packages: vec![
                SystemPackage {
                    name: "neovim".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "git".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "gh".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "pre-commit".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "nixd".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "nixfmt-rfc-style".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "cmake".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "rustup".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "ruby".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "awscli2".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "google-cloud-sdk".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "turso-cli".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "cloudflared".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "atlas".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "golangci-lint".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "python314".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "pipx".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "bun".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "coreutils".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "wget".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "rclone".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "p7zip".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "dust".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "bottom".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "defaultbrowser".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "zoxide".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "bat".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "eza".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "jq".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "yq".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "pandoc".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "pv".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "ffmpeg".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "imagemagick".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "yt-dlp".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "gnupg".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "knot-dns".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "nmap".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "fastfetch".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "lolcat".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "git-credential-manager".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "audacity".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "raycast".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "qbittorrent".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "monitorcontrol".to_string(),
                    version: None,
                },
                SystemPackage {
                    name: "wireshark-qt".to_string(),
                    version: None,
                },
            ],
            homebrew_brews: vec![
                "bettercap".to_string(),
                "gnupg".to_string(),
                "go".to_string(),
                "nvm".to_string(),
                "pnpm".to_string(),
                "handbrake".to_string(),
                "paperjam".to_string(),
                "gnu-sed".to_string(),
            ],
            homebrew_casks: vec![
                "figma".to_string(),
                "loom".to_string(),
                "ukelele".to_string(),
                "amie".to_string(),
                "orbstack".to_string(),
                "linear-linear".to_string(),
                "shottr".to_string(),
                "tailscale".to_string(),
                "stats".to_string(),
                "karabiner-elements".to_string(),
                "vlc".to_string(),
                "rustdesk".to_string(),
                "handbrake".to_string(),
                "1password".to_string(),
                "blender".to_string(),
                "thunderbird".to_string(),
                "zotero".to_string(),
                "github".to_string(),
                "jetbrains-toolbox".to_string(),
                "adobe-creative-cloud".to_string(),
                "microsoft-openjdk@21".to_string(),
                "swiftdefaultappsprefpane".to_string(),
                "meetingbar".to_string(),
                "lunar-client".to_string(),
                "whisky".to_string(),
                "steam".to_string(),
                "zed".to_string(),
                "visual-studio-code".to_string(),
                "vscodium".to_string(),
                "cursor".to_string(),
                "utm".to_string(),
                "signal".to_string(),
                "microsoft-powerpoint".to_string(),
                "discord".to_string(),
                "slack".to_string(),
                "parsec".to_string(),
                "obs".to_string(),
                "obsidian".to_string(),
                "ollama".to_string(),
                "veracrypt".to_string(),
                "warp".to_string(),
                "tor-browser".to_string(),
                "arc".to_string(),
                "librewolf".to_string(),
                "firefox@developer-edition".to_string(),
                "eloston-chromium".to_string(),
                "zen".to_string(),
            ],
            system_defaults: HashMap::new(),
        }
    }
}

pub async fn build_configuration(flake_path: &str) -> Result<()> {
    println!("Building configuration for flake: {}", flake_path);

    let output = AsyncCommand::new("nix")
        .args(&["run", "nix-darwin", "--", "build", "--flake", flake_path])
        .output()
        .await
        .context("Failed to execute nix build command")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Build failed: {}", stderr);
    }

    println!("Build completed successfully");
    Ok(())
}

pub async fn switch_configuration(flake_path: &str) -> Result<()> {
    println!("Switching to configuration for flake: {}", flake_path);

    let output = AsyncCommand::new("sudo")
        .args(&["darwin-rebuild", "switch", "--flake", flake_path])
        .output()
        .await
        .context("Failed to execute darwin-rebuild switch command")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Switch failed: {}", stderr);
    }

    println!("Switch completed successfully");
    Ok(())
}

pub async fn check_flake() -> Result<()> {
    println!("Checking flake configuration...");

    let output = AsyncCommand::new("nix")
        .args(&["flake", "check"])
        .output()
        .await
        .context("Failed to execute nix flake check command")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Flake check failed: {}", stderr);
    }

    println!("Flake check passed");
    Ok(())
}
