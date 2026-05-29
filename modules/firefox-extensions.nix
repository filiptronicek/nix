{pkgs, ...}: let
  amoUrl = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";

  # addon-id → AMO slug
  amoExtensions = {
    # Privacy / ad blocking
    "uBlock0@raymondhill.net" = "ublock-origin";
    "addon@darkreader.org" = "darkreader";
    "jid1-ZAdIEUB7XOzOJw@jetpack" = "duckduckgo-for-firefox";
    "@contain-facebook" = "facebook-container";
    "7esoorv3@alefvanoon.anonaddy.me" = "libredirect";
    "idcac-pub@guus.ninja" = "istilldontcareaboutcookies";

    # Productivity / utilities
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
    "languagetool-webextension@languagetool.org" = "languagetool";
    "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = "refined-github-";
    "cookie-manager@robwu.nl" = "a-cookie-manager";
    "clipper@obsidian.md" = "web-clipper-obsidian";
    "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = "user-agent-string-switcher";
    "@react-devtools" = "react-devtools";
    "{dbcc42f9-c979-4f53-8a95-a102fbff3bbe}" = "onahq";

    # YouTube tweaks
    "sponsorBlocker@ajay.app" = "sponsorblock";
    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = "return-youtube-dislikes";
    "{84c8edb0-65ca-43a5-bc53-0e80f41486e1}" = "tweaks-for-youtube";
    "myallychou@gmail.com" = "youtube-recommended-videos"; # Unhook

    # Wikipedia
    "{e9090647-32ff-48e4-9c3c-1361e8fd270e}" = "modern-for-wikipedia";

    # Search
    "search@kagi.com" = "kagi-search-for-firefox";
    "privacypass@kagi.com" = "kagi-privacy-pass";

    "webextension@metamask.io" = "ether-metamask";
    "wappalyzer@crunchlabz.com" = "wappalyzer";
    "{d6f0f975-91a3-4d78-96f7-5f1859ad18b6}" = "hlídač-shopů";
    "{47817be9-3851-41b6-b251-67072f984b72}" = "vše";
    "{48748554-4c01-49e8-94af-79662bf34d50}" = "privacy-pass"; # Silk
  };

  # Extensions whose .xpi isn't on AMO — e.g. Zotero distributes their
  # own. Add as `"<addon-id>" = "<direct-xpi-url>";`.
  extraExtensions = {
    "zotero@chnm.gmu.edu" = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-latest.xpi";
  };

  # Extensions that should also run in private browsing windows.
  privateBrowsing = [
    "uBlock0@raymondhill.net"
    "{dbcc42f9-c979-4f53-8a95-a102fbff3bbe}" # Ona
    "search@kagi.com" # Kagi Search
  ];

  mkPolicy = id: url:
    {
      installation_mode = "normal_installed";
      install_url = url;
    }
    // (
      if builtins.elem id privateBrowsing
      then {private_browsing = true;}
      else {}
    );

  extensionSettings =
    (builtins.mapAttrs (id: slug: mkPolicy id (amoUrl slug)) amoExtensions)
    // (builtins.mapAttrs (id: url: mkPolicy id url) extraExtensions);

  policies = {
    policies = {
      ExtensionSettings = extensionSettings;
    };
  };

  policiesJson = pkgs.writeText "firefox-policies.json" (builtins.toJSON policies);
in {
  system.activationScripts.extraActivation.text = ''
    # Firefox enterprise policies — declarative extension list.
    install -d -m 755 "/Library/Application Support/Mozilla"
    install -m 644 ${policiesJson} "/Library/Application Support/Mozilla/policies.json"
  '';
}
