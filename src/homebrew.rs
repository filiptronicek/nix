use anyhow::{Context, Result};
use tokio::process::Command;

pub async fn install_homebrew_packages(brews: &[String], casks: &[String]) -> Result<()> {
    println!("Installing Homebrew packages...");

    // Install brews
    if !brews.is_empty() {
        println!("Installing {} brew packages...", brews.len());
        for brew in brews {
            install_brew(brew).await?;
        }
    }

    // Install casks
    if !casks.is_empty() {
        println!("Installing {} cask packages...", casks.len());
        for cask in casks {
            install_cask(cask).await?;
        }
    }

    println!("Homebrew packages installed successfully");
    Ok(())
}

async fn install_brew(package: &str) -> Result<()> {
    let output = Command::new("brew")
        .args(&["install", package])
        .output()
        .await
        .context(format!("Failed to install brew package: {}", package))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        // Don't fail if package is already installed
        if !stderr.contains("already installed") {
            anyhow::bail!("Failed to install brew {}: {}", package, stderr);
        }
    }

    Ok(())
}

async fn install_cask(package: &str) -> Result<()> {
    let output = Command::new("brew")
        .args(&["install", "--cask", package])
        .output()
        .await
        .context(format!("Failed to install cask package: {}", package))?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        // Don't fail if package is already installed
        if !stderr.contains("already installed") {
            anyhow::bail!("Failed to install cask {}: {}", package, stderr);
        }
    }

    Ok(())
}

pub async fn update_homebrew() -> Result<()> {
    println!("Updating Homebrew...");

    let output = Command::new("brew")
        .args(&["update"])
        .output()
        .await
        .context("Failed to update Homebrew")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Failed to update Homebrew: {}", stderr);
    }

    let output = Command::new("brew")
        .args(&["upgrade"])
        .output()
        .await
        .context("Failed to upgrade Homebrew packages")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Failed to upgrade Homebrew packages: {}", stderr);
    }

    println!("Homebrew updated successfully");
    Ok(())
}

pub async fn cleanup_homebrew() -> Result<()> {
    println!("Cleaning up Homebrew...");

    let output = Command::new("brew")
        .args(&["cleanup"])
        .output()
        .await
        .context("Failed to cleanup Homebrew")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        println!("Warning: Homebrew cleanup failed: {}", stderr);
    }

    println!("Homebrew cleanup completed");
    Ok(())
}
