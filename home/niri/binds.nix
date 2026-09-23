{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.niri = {
    settings = {
      # Lid switch - lives in a top-level `switch-events` block, not `binds`.
      # Locks via noctalia (matches Mod+L below), not hyprlock.
      #
      # noctalia v5 rewrote its CLI: binary is `noctalia` (not `noctalia-shell`),
      # and IPC calls are `noctalia msg <command...>` instead of
      # `noctalia-shell ipc call <target> <action>`.
      switch-events.lid-close.spawn = ["noctalia" "msg" "session" "lock"];

      binds = {
        # launch-or-focus.sh used hyprctl to find/focus a running instance;
        # ~/.local/scripts/niri/launch-or-focus.sh (scripts.nix) is the same
        # logic driven by `niri msg` instead. Also dropped the `uwsm app --`
        # launch-command wrapper here (and below) - it requires a UWSM-managed
        # session, which this niri session isn't (see chat).
        #
        # Using spawn-sh (runs via `sh -c`) rather than spawn (execs argv
        # directly, no shell involved) - `spawn` never expands the leading
        # `~` in these paths, so it was silently trying to open a file
        # literally named `~` and failing.
        "Mod+M".spawn-sh = "bash ~/.local/scripts/niri/launch-or-focus.sh spotify";
        "Mod+O".spawn-sh = ''bash ~/.local/scripts/niri/launch-or-focus.sh obsidian "obsidian -disable-gpu --enable-wayland-ime"'';
        "Mod+Slash".spawn-sh = "bash ~/.local/scripts/niri/launch-or-focus.sh keepassxc";
        "Mod+G".spawn-sh = "bash ~/.local/scripts/niri/launch-or-focus.sh signal signal-desktop";

        # launch-browser.sh doesn't touch hyprctl, but it does wrap the
        # browser launch in `uwsm app --` - same problem as above, so this
        # uses the niri-native copy (scripts.nix) with that wrapper dropped.
        "Mod+B".spawn-sh = "bash ~/.local/scripts/niri/launch-browser.sh";
        "Mod+Shift+B".spawn-sh = "bash ~/.local/scripts/niri/launch-browser.sh --private";

        # Pending your answer: still don't know what these restart (waybar?
        # noctalia? a launcher called "walker"?), so still can't translate.
        # "Mod+Shift+R".spawn-sh = "bash ~/.local/scripts/hypr/restart_bar.sh";
        # "Mod+Shift+W".spawn-sh = "bash ~/.local/scripts/hypr/restart_walker.sh";

        # noctalia IPC (v5 syntax - see switch-events above).
        "Mod+R".spawn = ["noctalia" "msg" "panel-toggle" "launcher"];
        "Mod+S".spawn = ["noctalia" "msg" "panel-toggle" "control-center"];
        "Mod+Comma".spawn = ["noctalia" "msg" "settings-toggle"];
        "Mod+L".spawn = ["noctalia" "msg" "session" "lock"];

        "Mod+Q".spawn = ["kitty"];
        "Mod+C".close-window = {};
        "Mod+E".spawn = ["nemo"];
        "Mod+V".toggle-window-floating = {};

        "Mod+Space" = {
          _props.repeat = false;
          toggle-overview = {};
        };

        # Toggles the focused window's column between full width and half
        # width (via the two-entry preset-column-widths list in niri.nix) -
        # distinct from Mod+F's true fullscreen (which also hides gaps/bar).
        "Mod+J".switch-preset-column-width = {};

        # Toggles between 1/3 and 2/3 width - see the script's comment
        # (scripts.nix) for why this needs a script rather than a bind.
        "Mod+Shift+J".spawn-sh = "bash ~/.local/scripts/niri/toggle-column-width-thirds.sh";

        # hyprshot depends on hyprctl and can't run under niri at all; using
        # niri's own interactive screenshot UI instead (see screenshot-path
        # in niri.nix).
        "Mod+Shift+S".screenshot = {};

        "Mod+F".fullscreen-window = {};

        "Mod+Ctrl+Left".move-column-left = {};
        "Mod+Ctrl+Right".move-column-right = {};
        "Mod+Ctrl+F".expand-column-to-available-width = {};

        # niri's own default binds - not carried over automatically since
        # this `binds` block fully replaces the built-in defaults, so added
        # explicitly. Merges the focused window into the adjacent column, or
        # pops it back out into its own column if it's already in one.
        "Mod+BracketLeft".consume-or-expel-window-left = {};
        "Mod+BracketRight".consume-or-expel-window-right = {};

        # rofi powermenu script isn't under .../hypr/ and (unlike hyprshot)
        # doesn't obviously need hyprctl - carried over as-is; flag if wrong.
        "Ctrl+Alt+Delete".spawn-sh = "bash ~/.config/rofi/powermenu/type-6/powermenu.sh";

        # forcekillactive has no niri equivalent (only a graceful close
        # exists) - mapped to the same close-window as Mod+C for now.
        "Mod+Shift+C".close-window = {};

        "Mod+Left".focus-column-left = {};
        "Mod+Right".focus-column-right = {};
        "Mod+Up".focus-window-up = {};
        "Mod+Down".focus-window-down = {};

        # swapwindow has no exact niri equivalent - closest primitives are
        # swap-window-left/right (columns) and move-window-up/down (reorder
        # within a column). See chat list.
        "Mod+Shift+Left".swap-window-left = {};
        "Mod+Shift+Right".swap-window-right = {};
        "Mod+Shift+Up".move-window-up = {};
        "Mod+Shift+Down".move-window-down = {};

        "Mod+1".focus-workspace = ["1"];
        "Mod+2".focus-workspace = ["2"];
        "Mod+3".focus-workspace = ["3"];
        "Mod+4".focus-workspace = ["4"];
        "Mod+5".focus-workspace = ["5"];
        "Mod+6".focus-workspace = ["6"];
        "Mod+7".focus-workspace = ["7"];
        "Mod+8".focus-workspace = ["8"];
        "Mod+9".focus-workspace = ["9"];
        "Mod+0".focus-workspace = ["10"];

        "Mod+Shift+1".move-column-to-workspace = ["1"];
        "Mod+Shift+2".move-column-to-workspace = ["2"];
        "Mod+Shift+3".move-column-to-workspace = ["3"];
        "Mod+Shift+4".move-column-to-workspace = ["4"];
        "Mod+Shift+5".move-column-to-workspace = ["5"];
        "Mod+Shift+6".move-column-to-workspace = ["6"];
        "Mod+Shift+7".move-column-to-workspace = ["7"];
        "Mod+Shift+8".move-column-to-workspace = ["8"];
        "Mod+Shift+9".move-column-to-workspace = ["9"];
        "Mod+Shift+0".move-column-to-workspace = ["10"];

        "Mod+Minus".set-column-width = ["-100"];
        "Mod+Equal".set-column-width = ["+100"];
        "Mod+Shift+Minus".set-window-height = ["-100"];
        "Mod+Shift+Equal".set-window-height = ["+100"];

        # Bound once here rather than twice like the Hyprland config did
        # (plain `bind` + `bindle` both claimed these keys there - niri
        # rejects duplicate binds on the same key). Going with the
        # sound-up/sound-down scripts, matching the brightness binds below;
        # tell me if you actually want raw pactl instead.
        "XF86AudioRaiseVolume" = {
          _props."allow-when-locked" = true;
          spawn-sh = "sound-up";
        };
        "XF86AudioLowerVolume" = {
          _props."allow-when-locked" = true;
          spawn-sh = "sound-down";
        };

        "Mod+K".spawn = ["rofi" "-show" "calc" "-modi" "calc" "-no-show-match" "-no-sort" "-no-persist-history"];
        "Mod+Period".spawn = ["rofi" "-modi" "emoji" "-show" "emoji"];

        "Pause".spawn = ["wl-freeze" "-a"];

        # mouse:272/273 movewindow/resizewindow dropped - niri only supports
        # mod+drag move/resize on floating windows, and it's built in (not
        # bind-configurable); tiled windows are keyboard-only. See chat list.

        "XF86AudioMute" = {
          _props."allow-when-locked" = true;
          spawn-sh = "wpctl set-mute @DEFAULT_SINK@ toggle";
        };
        "XF86AudioPlay" = {
          _props."allow-when-locked" = true;
          spawn = ["playerctl" "-i" "kdeconnect" "play-pause"];
        };
        "XF86AudioNext" = {
          _props."allow-when-locked" = true;
          spawn = ["playerctl" "-i" "kdeconnect" "next"];
        };
        "XF86AudioPrev" = {
          _props."allow-when-locked" = true;
          spawn = ["playerctl" "-i" "kdeconnect" "previous"];
        };

        "XF86MonBrightnessUp" = {
          _props."allow-when-locked" = true;
          spawn-sh = "brightness-up";
        };
        "XF86MonBrightnessDown" = {
          _props."allow-when-locked" = true;
          spawn-sh = "brightness-down";
        };
      };
    };
  };
}
