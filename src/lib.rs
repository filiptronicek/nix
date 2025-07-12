use std::path::Path;
use anyhow::Result;

pub fn parse_flake_content(content: &str) -> Result<FlakeInfo> {
    let mut packages = Vec::new();
    let mut brews = Vec::new();
    let mut casks = Vec::new();

    for line in content.lines() {
        let trimmed = line.trim();
        
        if trimmed.starts_with("pkgs.") && !trimmed.contains("//") {
            if let Some(pkg) = extract_package_name(trimmed) {
                packages.push(pkg);
            }
        }
        
        if trimmed.starts_with("\"") && trimmed.ends_with("\"") {
            let name = trimmed.trim_matches('"');
            if line.contains("brews") {
                brews.push(name.to_string());
            } else if line.contains("casks") {
                casks.push(name.to_string());
            }
        }
    }

    Ok(FlakeInfo {
        packages,
        brews,
        casks,
    })
}

fn extract_package_name(line: &str) -> Option<String> {
    line.strip_prefix("pkgs.")
        .map(|s| s.trim_end_matches(';').trim_end_matches(',').to_string())
}

pub fn validate_flake_file(path: &Path) -> Result<bool> {
    if !path.exists() {
        return Ok(false);
    }

    let content = std::fs::read_to_string(path)?;
    
    let has_inputs = content.contains("inputs");
    let has_outputs = content.contains("outputs");
    let has_system_packages = content.contains("environment.systemPackages");
    
    Ok(has_inputs && has_outputs && has_system_packages)
}

#[derive(Debug)]
pub struct FlakeInfo {
    pub packages: Vec<String>,
    pub brews: Vec<String>,
    pub casks: Vec<String>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_package_name() {
        assert_eq!(extract_package_name("pkgs.neovim"), Some("neovim".to_string()));
        assert_eq!(extract_package_name("pkgs.git,"), Some("git".to_string()));
        assert_eq!(extract_package_name("pkgs.rustup;"), Some("rustup".to_string()));
    }

    #[test]
    fn test_parse_flake_content() {
        let content = r#"
            environment.systemPackages = [
                pkgs.neovim
                pkgs.git
                pkgs.rustup
            ];
            brews = [
                "go"
                "nvm"
            ];
            casks = [
                "figma"
                "arc"
            ];
        "#;

        let info = parse_flake_content(content).unwrap();
        assert!(info.packages.contains(&"neovim".to_string()));
        assert!(info.packages.contains(&"git".to_string()));
        assert!(info.packages.contains(&"rustup".to_string()));
    }
}
