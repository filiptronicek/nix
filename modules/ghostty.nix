{ ... }:
{
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "light:GitHub Light Default,dark:GitHub Dark Default";
      font-family = "JetBrains Mono";
      font-feature = [
        "zero" # slashed zeros
        "ss02" # alternate `=>`, `>=`, `<=` arrow forms
        "ss19" # dotted zero alternative styling
      ];
    };
  };
}
