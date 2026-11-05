{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    xwayland.enable = true;
    configType = "lua";
    settings = {
      config = {
        # Built-in scrolling layout, tuned to behave like the niri session
        # (home/niri/niri.nix).
        scrolling = {
          # A lone column spans the whole screen (Hyprland would center it otherwise).
          fullscreen_on_one_column = true;
          # Default width for new columns (niri's default is also 1/2).
          column_width = 0.5;
          # Mirrors niri's preset-column-widths: SUPER+J (colresize +conf)
          # toggles between half and full width.
          explicit_column_widths = "0.5, 1.0";
          # Scroll just enough to bring the focused column into view, like
          # niri's default center-focused-column "never".
          focus_fit_method = 1;
          # niri stops at the first/last column instead of wrapping around.
          wrap_focus = false;
          wrap_swapcol = false;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          resize_on_border = false;
          allow_tearing = false;
          layout = "scrolling";
        };

        decoration = {
          # Matches niri's geometry-corner-radius.
          rounding = 20;
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

        animations.enabled = true;

        dwindle = {
          # pseudotile = true;
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
          kb_layout = "eu, us, de";
          kb_options = "caps:escape";
          numlock_by_default = true;
          follow_mouse = 1;
          sensitivity = 0.6;
          accel_profile = "flat";

          touchpad = {
            natural_scroll = true;
            scroll_factor = 0.5;
          };
        };
      };

      curve = {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [[0.05 0.9] [0.1 1.05]];
          }
        ];
      };

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 3;
          bezier = "myBezier";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 3;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5;
          bezier = "default";
        }
        {
          leaf = "borderangle";
          enabled = true;
          speed = 4;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
      ];

      window_rule = let
        class = c: {match.class = "^(${c})$";};
      in [
        {
          match.class = ".*";
          suppress_event = "maximize";
        }
        {
          match.fullscreen = true;
          opacity = 1.0;
        }
        (class "kitty" // {opacity = 0.9;})
        (class "spotify" // {opacity = 0.9;})
        {
          match.title = "^(Friends List)$";
          float = true;
          persistent_size = true;
        }
        (class "dev.noctalia.Noctalia"
          // {
            float = true;
            size = "1080 920";
          })

        (class "spotify" // {workspace = "6 silent";})
        (class "steam" // {workspace = "7 silent";})
        (class "org.keepassxc.KeePassXC" // {workspace = "9 silent";})
        {
          match.initial_title = "^(Unlock Database - KeePassXC)$";
          workspace = "unset";
        }
        # Full-width columns, like niri's `open-maximized` rules.
        (class "spotify" // {scrolling_width = 1.0;})
        (class "steam" // {scrolling_width = 1.0;})
        (class "org.keepassxc.KeePassXC" // {scrolling_width = 1.0;})

        (class "discord" // {workspace = "10 silent";})
        (class "vesktop" // {workspace = "10 silent";})

        (class "org.keepassxc.KeePassXC" // {no_screen_share = true;})

        # xwayland_bridge fix
        (class "xwaylandvideobridge"
          // {
            opacity = "0.0 override";
            no_anim = true;
            no_initial_focus = true;
            max_size = "1 1";
            no_blur = true;
            no_focus = true;
          })
      ];

      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-.*|panel|attached-panel)$";
          ignore_alpha = 0.5;
          blur = true;
          blur_popups = true;
        }
      ];
    };
  };
}
