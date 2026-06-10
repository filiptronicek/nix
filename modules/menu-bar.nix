{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.menuBar;
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;

  itemType = lib.types.oneOf [
    lib.types.str
    lib.types.path
    lib.types.package
  ];

  allowedItems = map (item: "${item}") cfg.allowedApps;
  deniedItems = map (item: "${item}") cfg.deniedApps;

  allowedJson = pkgs.writeText "menu-bar-allowed.json" (builtins.toJSON allowedItems);
  deniedJson = pkgs.writeText "menu-bar-denied.json" (builtins.toJSON deniedItems);

  applyMenuBarPreferences = pkgs.writeText "apply-menu-bar-preferences.py" ''
    import json
    import os
    import plistlib
    import subprocess
    import sys
    import tempfile


    def read_json(path):
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)


    def app_bundle_ids(app_path):
        bundle_ids = []
        info_paths = []

        main_info = os.path.join(app_path, "Contents", "Info.plist")
        if os.path.exists(main_info):
            info_paths.append(main_info)

        login_items = os.path.join(app_path, "Contents", "Library", "LoginItems")
        if os.path.isdir(login_items):
            for name in os.listdir(login_items):
                if name.endswith(".app"):
                    info_paths.append(os.path.join(login_items, name, "Contents", "Info.plist"))

        for info_path in info_paths:
            try:
                with open(info_path, "rb") as handle:
                    bundle_id = plistlib.load(handle).get("CFBundleIdentifier")
            except Exception as error:
                print(f"Warning: could not read bundle id from {info_path}: {error}", file=sys.stderr)
                continue

            if bundle_id and bundle_id not in bundle_ids:
                bundle_ids.append(bundle_id)

        return bundle_ids


    def resolve_item(item):
        if "/" not in item and not item.endswith(".app"):
            return [item]

        path = os.path.expanduser(item)
        if not os.path.exists(path):
            print(f"Warning: menu bar item path does not exist: {item}", file=sys.stderr)
            return []

        app_paths = []
        if path.endswith(".app"):
            app_paths.append(path)
        else:
            for root, dirs, _files in os.walk(path):
                for name in list(dirs):
                    if name.endswith(".app"):
                        app_paths.append(os.path.join(root, name))
                        dirs.remove(name)

        bundle_ids = []
        for app_path in app_paths:
            for bundle_id in app_bundle_ids(app_path):
                if bundle_id not in bundle_ids:
                    bundle_ids.append(bundle_id)

        if not bundle_ids:
            print(f"Warning: no app bundle ids found for menu bar item: {item}", file=sys.stderr)

        return bundle_ids


    def bundle_id_for_location(location):
        if not isinstance(location, dict):
            return None

        bundle = location.get("bundle")
        if not isinstance(bundle, dict):
            return None

        return bundle.get("_0")


    def main():
        if len(sys.argv) != 4:
            print("usage: apply-menu-bar-preferences.py HOME ALLOWED_JSON DENIED_JSON", file=sys.stderr)
            return 2

        home, allowed_path, denied_path = sys.argv[1:]
        pref_path = os.path.join(
            home,
            "Library",
            "Group Containers",
            "group.com.apple.controlcenter",
            "Library",
            "Preferences",
            "group.com.apple.controlcenter.plist",
        )

        if not os.path.exists(pref_path):
            print(f"Warning: Control Center preferences do not exist yet: {pref_path}", file=sys.stderr)
            return 0

        allowed = set()
        denied = set()
        for item in read_json(allowed_path):
            allowed.update(resolve_item(item))
        for item in read_json(denied_path):
            denied.update(resolve_item(item))

        overlap = allowed & denied
        if overlap:
            print(
                f"Error: menu bar apps cannot be both allowed and denied: {', '.join(sorted(overlap))}",
                file=sys.stderr,
            )
            return 1

        with open(pref_path, "rb") as handle:
            outer = plistlib.load(handle)

        tracked_data = outer.get("trackedApplications")
        if not isinstance(tracked_data, bytes):
            print("Warning: Control Center trackedApplications is missing or not data.", file=sys.stderr)
            return 0

        tracked = plistlib.loads(tracked_data)
        if not isinstance(tracked, list):
            print("Warning: Control Center trackedApplications is not an array.", file=sys.stderr)
            return 0

        wanted = {bundle_id: True for bundle_id in allowed}
        wanted.update({bundle_id: False for bundle_id in denied})

        seen = set()
        changed = False
        for entry in tracked:
            if not isinstance(entry, dict) or "isAllowed" not in entry:
                continue

            bundle_id = bundle_id_for_location(entry.get("location"))
            if bundle_id not in wanted:
                continue

            seen.add(bundle_id)
            new_value = wanted[bundle_id]
            if entry.get("isAllowed") != new_value:
                entry["isAllowed"] = new_value
                changed = True
                print(f"menu bar: set {bundle_id} isAllowed={new_value}")

        for bundle_id in sorted(set(wanted) - seen):
            print(f"Warning: menu bar app is not tracked by macOS yet: {bundle_id}", file=sys.stderr)

        if not changed:
            print("menu bar: no changes needed")
            return 0

        outer["trackedApplications"] = plistlib.dumps(tracked, fmt=plistlib.FMT_BINARY)
        directory = os.path.dirname(pref_path)
        with tempfile.NamedTemporaryFile("wb", dir=directory, delete=False) as handle:
            temp_path = handle.name
            plistlib.dump(outer, handle, fmt=plistlib.FMT_BINARY)

        os.replace(temp_path, pref_path)
        subprocess.run(["killall", "cfprefsd"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        return 0


    if __name__ == "__main__":
        raise SystemExit(main())
  '';
in {
  options.local.menuBar = {
    allowedApps = lib.mkOption {
      type = lib.types.listOf itemType;
      default = [];
      description = ''
        Bundle identifiers, .app paths, or packages whose macOS menu bar items
        should be allowed in System Settings.
      '';
    };

    deniedApps = lib.mkOption {
      type = lib.types.listOf itemType;
      default = [];
      description = ''
        Bundle identifiers, .app paths, or packages whose macOS menu bar items
        should be hidden by System Settings.
      '';
    };
  };

  config = lib.mkIf (cfg.allowedApps != [] || cfg.deniedApps != []) {
    system.activationScripts.postActivation.text = ''
      echo >&2 "Configuring native macOS menu bar app permissions..."
      sudo -u ${user} ${pkgs.python314}/bin/python ${applyMenuBarPreferences} \
        ${lib.escapeShellArg home} \
        ${allowedJson} \
        ${deniedJson}
    '';
  };
}
