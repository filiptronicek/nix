{
  config,
  pkgs,
  ...
}: let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  karabinerConfig = {
    global = {
      show_in_menu_bar = false;
    };
    profiles = [
      {
        complex_modifications = {
          rules = [
            {
              description = "Caps Lock → Hyper (Control+Option+Shift+Command)";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      key_code = "left_shift";
                      modifiers = ["left_control" "left_option" "left_command"];
                    }
                  ];
                }
              ];
            }
            {
              description = "CleanShot: Cmd+Shift+3 captures screen, Cmd+Shift+4 captures area";
              manipulators =
                map (binding: {
                  type = "basic";
                  from = {
                    key_code = binding.key;
                    modifiers = {
                      mandatory = ["command" "shift"];
                      # Extra Control/Option modifiers must retain native behavior.
                      optional = ["caps_lock"];
                    };
                  };
                  to = [
                    {
                      shell_command = "/usr/bin/open -g 'cleanshot://${binding.action}'";
                      repeat = false;
                    }
                  ];
                }) [
                  {
                    key = "3";
                    action = "capture-fullscreen";
                  }
                  {
                    key = "4";
                    action = "capture-area";
                  }
                ];
            }
            {
              description = "Map x to alt+g";
              enabled = false;
              manipulators = [
                {
                  from = {
                    pointing_button = "button2";
                  };
                  to = [
                    {
                      key_code = "g";
                      modifiers = ["left_option"];
                    }
                  ];
                  type = "basic";
                }
              ];
            }
            {
              description = "Finder: Cmd+Shift+C copies selected items as pathnames";
              manipulators = [
                {
                  conditions = [
                    {
                      bundle_identifiers = [
                        "^com\\.apple\\.finder$"
                      ];
                      type = "frontmost_application_if";
                    }
                  ];
                  from = {
                    key_code = "c";
                    modifiers = {
                      mandatory = [
                        "left_command"
                        "left_shift"
                      ];
                      optional = ["any"];
                    };
                  };
                  to = [
                    {
                      key_code = "c";
                      modifiers = [
                        "left_command"
                        "left_option"
                      ];
                    }
                  ];
                  type = "basic";
                }
              ];
            }
          ];
        };
        devices = [
          {
            fn_function_keys = [
              {
                from = {
                  key_code = "f5";
                };
                to = [
                  {
                    key_code = "f20";
                  }
                ];
              }
            ];
            identifiers = {
              is_keyboard = true;
            };
          }
          {
            identifiers = {
              is_keyboard = true;
              product_id = 591;
              vendor_id = 1452;
            };
            simple_modifications = [
              {
                from = {
                  key_code = "right_command";
                };
                to = [
                  {
                    key_code = "right_option";
                  }
                ];
              }
            ];
          }
          {
            identifiers = {
              is_game_pad = true;
              product_id = 3302;
              vendor_id = 1356;
            };
            simple_modifications = [
              {
                from = {
                  pointing_button = "button5";
                };
                to = [
                  {
                    key_code = "left_arrow";
                  }
                ];
              }
              {
                from = {
                  pointing_button = "button6";
                };
                to = [
                  {
                    key_code = "right_arrow";
                  }
                ];
              }
            ];
          }
        ];
        name = "Default profile";
        selected = true;
        simple_modifications = [
          {
            from = {
              key_code = "page_down";
            };
            to = [
              {
                key_code = "f20";
              }
            ];
          }
        ];
        virtual_hid_keyboard = {
          country_code = 0;
          keyboard_type_v2 = "iso";
        };
      }
    ];
  };

  karabinerJson = pkgs.writeText "karabiner.json" (builtins.toJSON karabinerConfig);
in {
  system.activationScripts.postActivation.text = ''
    install -d -m 755 "${home}/.config/karabiner"
    install -m 644 "${karabinerJson}" "${home}/.config/karabiner/karabiner.json"
    chown -R ${user}:staff "${home}/.config/karabiner"
  '';
}
