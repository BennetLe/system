{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      plugin = {
        hyprscrolling = {
          fullscreen_on_one_column = true;
          focus_fit_method = 1;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1;
        inactive_opacity = 1;
        fullscreen_opacity = 1;

        shadow = {
          enabled = true;
          range = 2;
          render_power = 3;
        };

        blur = {
          enabled = true;
          size = 2;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "us, de";
        kb_variant = [];
        kb_model = [];
        kb_options = ["caps:escape"];
        numlock_by_default = true;
        kb_rules = [];
        follow_mouse = 1;
        sensitivity = 0.6;
        accel_profile = "flat";

        touchpad = {
          natural_scroll = false;
        };
      };

      gestures = {
        workspace_swipe = false;
      };

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "opacity 1.0, fullscreen:(1)"
        "opacity 0.9, class:(kitty)"
        "opacity 0.9, class:(Spotify)"
        "float, title:(Friends List)"

        "workspace 6 silent, class:(Spotify)"
        "workspace 10 silent, class:(discord)"
        "workspace 10 silent, class:(vesktop)"
        "workspace 9 silent, class:(org.keepassxc.KeePassXC)"
        "workspace 7 silent, title:(Steam)"

        # xwayland_bridge fix
        "opacity 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        "maxsize 1 1, class:^(xwaylandvideobridge)$"
        "noblur, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
      ];
    };
  };
}
