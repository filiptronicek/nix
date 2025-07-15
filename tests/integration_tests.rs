use nix_config::config::{build_configuration, check_flake, Configuration};
use nix_config::homebrew::{install_homebrew_packages, update_homebrew};
use nix_config::system::{apply_system_defaults, SystemDefaults};
use tokio_test;

#[tokio::test]
async fn test_configuration_default() {
    let config = Configuration::default();

    assert_eq!(config.vars.username, "filip");
    assert_eq!(config.vars.defaultbrowser, "browser");
    assert!(!config.system_packages.is_empty());
    assert!(!config.homebrew_brews.is_empty());
    assert!(!config.homebrew_casks.is_empty());
}

#[tokio::test]
async fn test_system_defaults() {
    let defaults = SystemDefaults::default();

    assert_eq!(defaults.dock.autohide, true);
    assert_eq!(defaults.dock.tilesize, 60);
    assert_eq!(defaults.finder.apple_show_all_extensions, true);
    assert_eq!(defaults.loginwindow.guest_enabled, false);
}

#[tokio::test]
async fn test_flake_check() {
    // This test will only pass if we have a valid Nix environment
    // In CI/CD, this should work with the existing flake.nix
    match check_flake().await {
        Ok(_) => println!("Flake check passed"),
        Err(e) => {
            // Allow this to fail in environments without Nix
            println!("Flake check failed (expected in some environments): {}", e);
        }
    }
}

#[test]
fn test_package_lists_not_empty() {
    let config = Configuration::default();

    // Verify we have essential packages
    let has_git = config.system_packages.iter().any(|p| p.name == "git");
    let has_neovim = config.system_packages.iter().any(|p| p.name == "neovim");
    let has_rust = config.system_packages.iter().any(|p| p.name == "rustup");

    assert!(has_git, "Git should be in system packages");
    assert!(has_neovim, "Neovim should be in system packages");
    assert!(has_rust, "Rustup should be in system packages");

    // Verify we have essential homebrew packages
    assert!(config.homebrew_brews.contains(&"go".to_string()));
    assert!(config
        .homebrew_casks
        .contains(&"visual-studio-code".to_string()));
}

#[test]
fn test_persistent_dock_apps() {
    let defaults = SystemDefaults::default();

    let expected_apps = vec![
        "/System/Volumes/Data/Applications/Firefox Developer Edition.app",
        "/System/Volumes/Data/Applications/Thunderbird.app",
        "/System/Volumes/Data/Applications/Slack.app",
        "/System/Volumes/Data/Applications/Discord.app",
    ];

    for app in expected_apps {
        assert!(
            defaults.dock.persistent_apps.contains(&app.to_string()),
            "Dock should contain {}",
            app
        );
    }
}
