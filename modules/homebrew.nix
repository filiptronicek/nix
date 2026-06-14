{config, ...}: {
  homebrew = {
    enable = true;

    brews = [
      "bettercap"
      "gnupg"
      "go"
      "pnpm"
      "handbrake"
      "paperjam"
      "gnu-sed"
      "php"
      "gitpod-io/tap/ona"
      "rust-analyzer"
    ];

    goPackages = [
      "github.com/filiptronicek/bruh"
      "github.com/mattn/bsky"
      "github.com/bufbuild/buf/cmd/buf"
      "github.com/go-delve/delve/cmd/dlv"
      "github.com/tantalor93/dnspyre/v2"
      "github.com/golangci/golangci-lint/cmd/golangci-lint"
      "golang.org/x/tools/gopls"
      "github.com/mitranim/gow"
      "github.com/fullstorydev/grpcurl/cmd/grpcurl"
      "github.com/interclip/iclip"
      "github.com/tdewolff/minify/v2/cmd/minify"
      "go.uber.org/mock/mockgen"
      "github.com/csweichel/oci-tool"
      "connectrpc.com/connect/cmd/protoc-gen-connect-go"
      "github.com/sudorandom/protoc-gen-connect-openapi"
      "google.golang.org/protobuf/cmd/protoc-gen-go"
      "google.golang.org/grpc/cmd/protoc-gen-go-grpc"
      "github.com/bufbuild/protoschema-plugins/cmd/protoc-gen-jsonschema"
      "github.com/gitpod-io/gitpod-next/api/go/tools/logfields/protoc-logfields"
      "github.com/boyter/scc/v3"
      "honnef.co/go/tools/cmd/staticcheck"
    ];

    casks = [
      "figma"
      "loom"
      "raycast"
      "orbstack"
      "tailscale-app"
      "linear"
      "1password"
      "github"
      "jetbrains-toolbox"

      "ukelele"
      "karabiner-elements"
      "stats"
      "shottr"
      "rustdesk"
      "wireshark-app"

      "xykong/tap/flux-markdown" # markdown rendering for QuickLook
      "hyperkey" # Caps Lock modifier for Super
      "typewhisper/tap/typewhisper" # STT

      "blender"
      "thunderbird"
      "zotero"
      "adobe-creative-cloud"
      "microsoft-openjdk@21"
      "omnissa-horizon-client"
      "cyberduck"

      "vlc"
      "handbrake-app"
      "kodi"

      "swiftdefaultappsprefpane"
      "meetingbar"

      "lunar-client"
      "whisky"
      "steam"

      "zed"
      "visual-studio-code"
      "vscodium"
      "cursor"

      "codex"
      "codex-app"

      "utm"
      "signal"
      "telegram"

      "microsoft-powerpoint"
      "microsoft-word"

      "discord"
      "slack"
      "parsec"
      "obs"
      "obsidian"
      "ollama-app"
      "macfuse"
      "veracrypt"
      "warp"

      "tor-browser"
      "arc"
      "librewolf"
      "firefox@developer-edition"
      "ungoogled-chromium"
      "zen"
    ];

    onActivation = {
      # autoUpdate = true; # these two somehow break upgrading the go packages listed above.
      # upgrade = true;
      cleanup = "zap";
    };
  };

  system.activationScripts.postActivation.text = ''
    # Homebrew bundle cleanup removes unmanaged packages; this prunes cached downloads.
    if [ -x "${config.homebrew.prefix}/bin/brew" ]; then
      echo >&2 "Homebrew cache cleanup..."
      PATH="${config.homebrew.prefix}/bin:$PATH" \
        sudo \
          --preserve-env=PATH \
          --user=${config.homebrew.user} \
          --set-home \
          brew cleanup --prune=all -s || \
            echo >&2 "Warning: Homebrew cache cleanup failed; continuing activation."
    fi
  '';
}
