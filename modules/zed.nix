{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;
    package = null; # installed via cask

    # Allow Zed to write back to settings.json / keymap.json so transient
    # state (e.g. SSH host list, recent files) doesn't get clobbered on
    # every rebuild. Declared values below are the base; Zed-driven
    # changes accumulate on top.
    mutableUserSettings = true;
    mutableUserKeymaps = true;

    userSettings = {
      # UI
      ui_font_size = 16;
      buffer_font_size = 16;
      buffer_line_height = "comfortable";
      theme = {
        mode = "system";
        light = "GitHub Light";
        dark = "GitHub Dark Default";
      };

      # Behavior
      autosave = "on_focus_change";
      cli_default_open_behavior = "new_window";
      diff_view_style = "unified";
      soft_wrap = "editor_width";

      # Panel docking
      outline_panel.dock = "left";
      collaboration_panel.dock = "left";
      git_panel.dock = "left";
      project_panel = {
        dock = "right";
        git_status = true;
      };
      agent = {
        dock = "right";
        tool_permissions.default = "allow";
        model_parameters = [];
      };

      # Edit predictions (Copilot), but not in Markdown or Plain Text
      edit_predictions.provider = "copilot";
      languages = {
        Markdown.show_edit_predictions = false;
        "Plain Text".show_edit_predictions = false;
        Nix = {
          formatter = {
            external = {
              command = "${pkgs.alejandra}/bin/alejandra";
              arguments = ["-"]; # read from stdin
            };
          };
          format_on_save = "on";
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "cmd-shift-j" = "workspace::ToggleZoom";
          "cmd-t" = "workspace::NewTerminal";
        };
      }
      {
        context = "Workspace";
        unbind = {
          "cmd-t" = "project_symbols::Toggle";
          "ctrl-~" = "workspace::NewTerminal";
        };
      }
      {
        context = "ProjectSearchBar";
        bindings = {
          "alt-cmd-shift-j" = "project_search::ToggleFilters";
        };
      }
      {
        context = "ProjectSearchView";
        bindings = {
          "alt-cmd-shift-j" = "project_search::ToggleFilters";
          "ctrl-alt-cmd-j" = "project_search::ToggleFilters";
        };
      }
    ];
  };
}
