{ ... }:
{
  # Firefox Developer Edition declarative config.

  programs.firefox = {
    enable = true;
    package = null;

    profiles.dev-edition-default = {
      id = 0;
      isDefault = true;
      name = "dev-edition-default";
      path = "dev-edition-default";

      settings = {
        # ─── Privacy / tracking protection ────────────────────────────────
        "browser.contentblocking.category" = "strict";
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.allow_list.baseline.enabled" = false;
        "privacy.trackingprotection.allow_list.convenience.enabled" = false;
        "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.bounceTrackingProtection.mode" = 1;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "privacy.userContext.extension" = "@contain-facebook";

        # ─── DNS-over-HTTPS + network ─────────────────────────────────────
        "network.trr.mode" = 3; # DoH strict; no system DNS fallback
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        "network.http.speculative-parallel-limit" = 0;
        "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
        "network.lna.blocking" = true;
        "dom.security.https_only_mode_pbm" = true;
        "dom.security.https_only_mode_ever_enabled_pbm" = true;

        # ─── Firefox AI / ML — everything off ─────────────────────────────
        "browser.ai.control.default" = "blocked";
        "browser.ai.control.linkPreviewKeyPoints" = "blocked";
        "browser.ai.control.pdfjsAltText" = "blocked";
        "browser.ai.control.sidebarChatbot" = "blocked";
        "browser.ai.control.smartTabGroups" = "blocked";
        "browser.ai.control.smartWindow" = "blocked";
        "browser.ai.control.translations" = "blocked";
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.page" = false;
        "browser.ml.linkPreview.enabled" = false;
        "browser.smartwindow.memories.generateFromConversation" = false;
        "browser.smartwindow.memories.generateFromHistory" = false;
        "browser.translations.enable" = false;
        "extensions.ml.enabled" = false;
        "pdfjs.enableAltText" = false;
        "signon.firefoxRelay.feature" = "disabled";

        # ─── UI / behavior ────────────────────────────────────────────────
        "browser.aboutConfig.showWarning" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = true; # MRU tab cycling
        "browser.display.document_color_use" = 0; # respect site colors
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.page" = 3; # restore previous session
        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.groups.smart.userEnabled" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.toolbars.bookmarks.showOtherBookmarks" = false;
        "browser.bookmarks.showMobileBookmarks" = false;
        "browser.download.useDownloadDir" = false; # ask where to save each
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.system.showWeatherOptIn" = false;
        "accessibility.typeaheadfind.flashBar" = 0;
        "sidebar.revamp" = true; # new sidebar UI
        "sidebar.verticalTabs" = true;
        "intl.accept_languages" = "en-us,en,cs,de-de";

        # ─── Devtools ─────────────────────────────────────────────────────
        "devtools.toolbox.host" = "right"; # dock on right
        "devtools.toolbox.zoomValue" = "1.1";
        "devtools.webconsole.timestampMessages" = true;
        "devtools.netmonitor.ui.default-raw-response" = true;
        "devtools.responsive.touchSimulation.enabled" = true;
        "devtools.responsive.reloadNotification.enabled" = false;
        "devtools.inspector.three-pane-enabled" = false;
      };
    };
  };
}
