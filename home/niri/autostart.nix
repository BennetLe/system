{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.niri = {
    settings = {
      _children = [
        # Not translated - Hyprland-specific / redundant under niri:
        # - "hyprctl dispatch workspace 1 &" (niri already starts on a workspace)
        # - "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        #   (niri-session already imports the full environment - see the
        #   `systemd.variables` option doc in home-manager's niri module)

        {spawn-sh-at-startup = "systemctl --user start hyprpolkitagent";}

        # Pending your answer (see chat): still don't know what this does.
        # {spawn-at-startup._args = ["bash" "~/.local/scripts/hypr/screensharing.sh"];}

        # start.sh doesn't touch hyprctl (nm-applet, easyeffects, solaar,
        # protonvpn-app, tailscale systray) - carried over as-is. This
        # already starts tailscale systray, so no separate entry for it below
        # (the Hyprland config started it twice: once here, once via a
        # `uwsm app --` exec-once line - not replicating that duplication).
        {spawn-sh-at-startup = "bash ~/.local/scripts/hypr/start.sh";}

        {spawn-at-startup._args = ["kdeconnect-indicator"];}
        {spawn-at-startup._args = ["noctalia"];}

        # Pending your answer: hyprsunset/hyprlauncher are Hyprland-branded -
        # unconfirmed whether they work standalone under niri.
        # {spawn-at-startup._args = ["hyprsunset"];}
        # {spawn-at-startup._args = ["hyprlauncher" "-d"];}
      ];
    };
  };
}
