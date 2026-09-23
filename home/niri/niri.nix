{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.niri = {
    enable = true;

    # `programs.niri` on the NixOS side (hosts/configuration.nix) already installs
    # the niri package, the portal and its systemd units, so don't duplicate them
    # here. `package` is left at its default so `checkConfig` (niri validate) still
    # runs against the generated config at build time.
    portalPackage = null;
    xwaylandSatellitePackage = null; # already in environment.systemPackages
    systemd.enable = false;

    settings = {
      input = {
        # Matches Hyprland's `input.follow_mouse = 1` (hover-to-focus).
        # niri only has an on/off flag here, not Hyprland's strict/loose
        # follow_mouse modes.
        focus-follows-mouse = {};

        # The reverse direction: when focus changes via keyboard (arrow
        # keys, launch-or-focus.sh's `focus-window --id`, workspace
        # switches, etc.) rather than the mouse, warp the cursor onto the
        # newly focused window too.
        warp-mouse-to-focus = {};

        keyboard = {
          xkb.layout = "eu,us,de";
          numlock = {};
        };

        touchpad = {
          tap = {};
          natural-scroll = {};
        };

        mouse = {
          # Matches Hyprland's `input.sensitivity = 0.6` - same libinput
          # accel-speed range (-1.0..1.0). Without this it defaults to 0.0,
          # which is why the cursor felt much slower than under Hyprland.
          accel-speed = 0.6;
          accel-profile = "flat";
        };
      };

      layout = {
        # niri has a single `gaps` value, unlike Hyprland's separate
        # gaps_in/gaps_out (5/10) - using the outer value as the closer match.
        gaps = 10;

        focus-ring.width = 2;

        # Approximates decoration.shadow { range=2 render_power=3 } - niri's
        # shadow model (softness/spread) doesn't map 1:1 to Hyprland's.
        shadow = {
          on = {};
          softness = 20;
          spread = 2;
        };

        # No niri equivalent for decoration.blur - niri does not render
        # background blur behind windows or layer-shell surfaces at all.

        # Two stops instead of niri's default 1/3, 1/2, 2/3 - "Mod+J"
        # (switch-preset-column-width, binds.nix) toggles cleanly between
        # exactly full width and half width.
        preset-column-widths._children = [
          {proportion = 0.5;}
          {proportion = 1.0;}
        ];
      };

      # Default is a spring (damping-ratio=1.0 stiffness=1000 epsilon=0.0001),
      # which takes noticeably longer than this to settle. Switching to a
      # short fixed-duration ease instead for a snappier, more predictable feel.
      animations.workspace-switch = {
        duration-ms = 150;
        curve = "ease-out-cubic";
      };

      prefer-no-csd = {};

      hotkey-overlay.skip-at-startup = {};

      # Allows noctalia to raise its own windows / notification actions to
      # focus without a valid xdg-activation serial (niri is stricter about
      # this by default than most compositors).
      debug.honor-xdg-activation-with-invalid-serial = {};

      # Matches $HYPRSHOT_DIR (home/bennet.nix, home/framework.nix) so the
      # native `screenshot` action (bound in binds.nix) lands in the same place
      # hyprshot used to.
      screenshot-path = "~/Pictures/Hyprshot/Screenshot from %Y-%m-%d %H-%M-%S.png";

      _children = [
        # Global (unmatched) window-rule - applies to every window.
        {
          window-rule._children = [
            {geometry-corner-radius = 20;}
            {clip-to-geometry = true;}
          ];
        }

        # noctalia's own settings window.
        {
          window-rule._children = [
            {match._props = {app-id = "dev.noctalia.Noctalia";};}
            {open-floating = true;}
            {default-column-width.fixed = 1080;}
            {default-window-height.fixed = 920;}
          ];
        }

        # Static workspaces 1-10 (named to mirror Hyprland's numbered
        # workspaces, so the window-rules below can pin apps to them the same
        # way the `workspace <n> silent` windowrules did) are declared
        # per-host, alongside their `open-on-output` pinning - see the
        # `wayland.windowManager.niri.settings` block in home/bennet.nix and
        # home/framework.nix, next to that host's existing Hyprland
        # `monitor`/`workspace` settings. They can't live here since a
        # workspace name can only be defined once across the merged config.

        # kitty / spotify opacity
        {
          window-rule._children = [
            {match._props = {app-id = "^kitty$";};}
            {opacity = 0.9;}
            # Opens at full column width; toggle back to half with Mod+J.
            {open-maximized = true;}
          ];
        }
        {
          window-rule._children = [
            # niri msg -j windows reports this as "Spotify" (capital S),
            # not "spotify" like the Hyprland config assumed.
            {match._props = {app-id = "^Spotify$";};}
            {opacity = 0.9;}
            {open-on-workspace = "6";}
            # Full-width column on whatever output it opens on.
            {open-maximized = true;}
          ];
        }
        {
          window-rule._children = [
            {match._props = {app-id = "^steam$";};}
            {open-on-workspace = "7";}
            {open-maximized = true;}
            # Stops the small Steam popup (e.g. the one that flashes up
            # when launching a game) from stealing focus/switching you to
            # workspace 7. Also applies to the main Steam client window
            # itself, since it shares the same app-id - it'll still open
            # pinned to workspace 7, just without grabbing focus.
            {open-focused = false;}
          ];
        }
        {
          window-rule._children = [
            {match._props = {app-id = "^org\\.keepassxc\\.KeePassXC$";};}
            # Mirrors the `initial_title ... workspace unset` exception: the
            # unlock dialog itself isn't pinned to workspace 9.
            {exclude._props = {title = "^Unlock Database - KeePassXC$";};}
            {open-on-workspace = "9";}
            {block-out-from = "screen-capture";}
            {open-maximized = true;}
          ];
        }
        {
          window-rule._children = [
            {match._props = {app-id = "^discord$";};}
            {open-on-workspace = "10";}
          ];
        }
        {
          window-rule._children = [
            {match._props = {app-id = "^vesktop$";};}
            {open-on-workspace = "10";}
          ];
        }
        {
          window-rule._children = [
            {match._props = {title = "^Friends List$";};}
            {open-floating = true;}
            # No niri equivalent for `persistent_size`.
          ];
        }
        # Omitted, no niri equivalent to translate meaningfully:
        # - "match:class .*, suppress_event maximize" (Hyprland-specific event)
        # - "match:fullscreen true, opacity 1.0" (niri has no is-fullscreen
        #   match predicate; opacity 1.0 is niri's default anyway)
        # - the xwaylandvideobridge hack (Hyprland+OBS-specific workaround;
        #   xwayland-satellite may not need it at all - revisit if it comes up)

        {
          layer-rule._children = [
            {match._props = {namespace = "^noctalia-background-.*$";};}
            # Approximates `ignore_alpha 0.5`; no niri equivalent for `blur`.
            {opacity = 0.5;}
          ];
        }
      ];
    };
  };
}
