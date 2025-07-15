use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::process::Command;

#[derive(Debug, Serialize, Deserialize)]
pub struct SystemDefaults {
    pub dock: DockSettings,
    pub finder: FinderSettings,
    pub loginwindow: LoginWindowSettings,
    pub nsglobal_domain: NSGlobalDomainSettings,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DockSettings {
    pub autohide: bool,
    pub tilesize: u32,
    pub persistent_apps: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct FinderSettings {
    pub apple_show_all_extensions: bool,
    pub apple_show_all_files: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginWindowSettings {
    pub guest_enabled: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct NSGlobalDomainSettings {
    pub swipe_scroll_direction: bool,
    pub apple_icu_force_24_hour_time: bool,
    pub apple_interface_style_switches_automatically: bool,
}

impl Default for SystemDefaults {
    fn default() -> Self {
        Self {
            dock: DockSettings {
                autohide: true,
                tilesize: 60,
                persistent_apps: vec![
                    "/System/Volumes/Data/Applications/Firefox Developer Edition.app".to_string(),
                    "/System/Volumes/Data/Applications/Thunderbird.app".to_string(),
                    "/System/Volumes/Data/Applications/Slack.app".to_string(),
                    "/System/Volumes/Data/Applications/Discord.app".to_string(),
                ],
            },
            finder: FinderSettings {
                apple_show_all_extensions: true,
                apple_show_all_files: true,
            },
            loginwindow: LoginWindowSettings {
                guest_enabled: false,
            },
            nsglobal_domain: NSGlobalDomainSettings {
                swipe_scroll_direction: false,
                apple_icu_force_24_hour_time: true,
                apple_interface_style_switches_automatically: true,
            },
        }
    }
}

pub async fn apply_system_defaults(defaults: &SystemDefaults) -> Result<()> {
    println!("Applying system defaults...");

    // Dock settings
    set_default(
        "com.apple.dock",
        "autohide",
        &defaults.dock.autohide.to_string(),
    )
    .await?;
    set_default(
        "com.apple.dock",
        "tilesize",
        &defaults.dock.tilesize.to_string(),
    )
    .await?;

    // Finder settings
    set_default(
        "com.apple.finder",
        "AppleShowAllExtensions",
        &defaults.finder.apple_show_all_extensions.to_string(),
    )
    .await?;
    set_default(
        "com.apple.finder",
        "AppleShowAllFiles",
        &defaults.finder.apple_show_all_files.to_string(),
    )
    .await?;

    // Login window settings
    set_default(
        "com.apple.loginwindow",
        "GuestEnabled",
        &defaults.loginwindow.guest_enabled.to_string(),
    )
    .await?;

    // NSGlobalDomain settings
    set_default(
        "NSGlobalDomain",
        "com.apple.swipescrolldirection",
        &defaults.nsglobal_domain.swipe_scroll_direction.to_string(),
    )
    .await?;
    set_default(
        "NSGlobalDomain",
        "AppleICUForce24HourTime",
        &defaults
            .nsglobal_domain
            .apple_icu_force_24_hour_time
            .to_string(),
    )
    .await?;
    set_default(
        "NSGlobalDomain",
        "AppleInterfaceStyleSwitchesAutomatically",
        &defaults
            .nsglobal_domain
            .apple_interface_style_switches_automatically
            .to_string(),
    )
    .await?;

    println!("System defaults applied successfully");
    Ok(())
}

async fn set_default(domain: &str, key: &str, value: &str) -> Result<()> {
    let output = Command::new("defaults")
        .args(&["write", domain, key, value])
        .output()
        .await
        .context(format!("Failed to set default for {}.{}", domain, key))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Failed to set default {}.{}: {}", domain, key, stderr);
    }

    Ok(())
}

pub async fn setup_activation_scripts(username: &str) -> Result<()> {
    println!("Setting up activation scripts...");

    // Set default browser
    let output = Command::new("sudo")
        .args(&["-u", username, "defaultbrowser", "browser"])
        .output()
        .await
        .context("Failed to set default browser")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        println!("Warning: Failed to set default browser: {}", stderr);
    }

    // Set rustup default
    let output = Command::new("rustup")
        .args(&["default", "stable"])
        .output()
        .await
        .context("Failed to set rustup default")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        println!("Warning: Failed to set rustup default: {}", stderr);
    }

    println!("Activation scripts completed");
    Ok(())
}
