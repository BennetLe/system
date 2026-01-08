{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "hyprctl dispatch workspace 1 &"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        # "hyprctl setcursors Sweet-cursor 24"
        "~/.local/scripts/hypr/screensharing.sh"
        "~/.local/scripts/hypr/start.sh"
        "kdeconnect-indicator"
        "hyprpanel"
        "hyprlauncher -d"
        "uwsm app -- tailscale systray"
      ];
    };
  };
}
