use anyhow::Result;
use clap::{Parser, Subcommand};

mod config;
mod homebrew;
mod system;

#[derive(Parser)]
#[command(name = "nix-config")]
#[command(about = "Rust-based Nix configuration management")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Build {
        #[arg(short, long)]
        flake: Option<String>,
    },
    Switch {
        #[arg(short, long)]
        flake: Option<String>,
    },
    Check,
    Apply {
        #[arg(short, long)]
        config_file: Option<String>,
    },
    Update,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Build { flake } => {
            let flake_path = flake.unwrap_or_else(|| ".#mbp".to_string());
            config::build_configuration(&flake_path).await?;
        }
        Commands::Switch { flake } => {
            let flake_path = flake.unwrap_or_else(|| ".#mbp".to_string());
            config::switch_configuration(&flake_path).await?;
        }
        Commands::Check => {
            config::check_flake().await?;
        }
        Commands::Apply { config_file: _ } => {
            let configuration = config::Configuration::default();

            // Apply system defaults
            let system_defaults = system::SystemDefaults::default();
            system::apply_system_defaults(&system_defaults).await?;

            // Setup activation scripts
            system::setup_activation_scripts(&configuration.vars.username).await?;

            // Install Homebrew packages
            homebrew::install_homebrew_packages(
                &configuration.homebrew_brews,
                &configuration.homebrew_casks,
            )
            .await?;

            println!("Configuration applied successfully");
        }
        Commands::Update => {
            // Update Nix flake
            config::check_flake().await?;

            // Update Homebrew
            homebrew::update_homebrew().await?;
            homebrew::cleanup_homebrew().await?;

            println!("System updated successfully");
        }
    }

    Ok(())
}
