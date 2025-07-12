use clap::{Parser, Subcommand};
use anyhow::Result;
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "nix-config-manager")]
#[command(about = "A Rust CLI tool for managing Nix configurations")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Validate {
        #[arg(short, long, default_value = "flake.nix")]
        file: PathBuf,
    },
    Update {
        #[arg(short, long)]
        dry_run: bool,
    },
    Packages {
        #[command(subcommand)]
        action: PackageAction,
    },
}

#[derive(Subcommand)]
enum PackageAction {
    List,
    Add { name: String },
    Remove { name: String },
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Validate { file } => {
            validate_flake(&file).await?;
        }
        Commands::Update { dry_run } => {
            update_system(dry_run).await?;
        }
        Commands::Packages { action } => {
            handle_packages(action).await?;
        }
    }

    Ok(())
}

async fn validate_flake(file: &PathBuf) -> Result<()> {
    println!("Validating Nix flake: {}", file.display());
    
    if !file.exists() {
        anyhow::bail!("Flake file does not exist: {}", file.display());
    }

    let content = std::fs::read_to_string(file)?;
    
    if content.contains("inputs") && content.contains("outputs") {
        println!("✓ Flake structure appears valid");
    } else {
        println!("⚠ Flake may be missing required sections");
    }

    Ok(())
}

async fn update_system(dry_run: bool) -> Result<()> {
    if dry_run {
        println!("Dry run: Would execute system update");
        return Ok(());
    }

    println!("Updating Nix configuration...");
    
    let output = std::process::Command::new("sudo")
        .args(&["darwin-rebuild", "switch", "--flake", ".#mbp"])
        .output()?;

    if output.status.success() {
        println!("✓ System updated successfully");
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Update failed: {}", stderr);
    }

    Ok(())
}

async fn handle_packages(action: PackageAction) -> Result<()> {
    match action {
        PackageAction::List => {
            println!("Listing installed packages...");
            list_packages().await?;
        }
        PackageAction::Add { name } => {
            println!("Adding package: {}", name);
            add_package(&name).await?;
        }
        PackageAction::Remove { name } => {
            println!("Removing package: {}", name);
            remove_package(&name).await?;
        }
    }
    Ok(())
}

async fn list_packages() -> Result<()> {
    let content = std::fs::read_to_string("flake.nix")?;
    
    println!("System packages found in flake.nix:");
    for line in content.lines() {
        if line.trim().starts_with("pkgs.") && !line.contains("//") {
            let pkg = line.trim()
                .strip_prefix("pkgs.")
                .unwrap_or(line.trim())
                .trim_end_matches(';')
                .trim_end_matches(',');
            println!("  - {}", pkg);
        }
    }
    
    Ok(())
}

async fn add_package(name: &str) -> Result<()> {
    println!("Package addition would modify flake.nix to include: pkgs.{}", name);
    println!("Note: Manual editing of flake.nix is recommended for now");
    Ok(())
}

async fn remove_package(name: &str) -> Result<()> {
    println!("Package removal would modify flake.nix to remove: pkgs.{}", name);
    println!("Note: Manual editing of flake.nix is recommended for now");
    Ok(())
}
