{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # niri-native replacement for ~/.local/scripts/hypr/launch-or-focus.sh, which
  # uses `hyprctl clients`/`hyprctl dispatch focuswindow` and so can't run under
  # niri. Same launch-or-focus behavior, driven by `niri msg` instead.
  #
  # Also drops the `uwsm app --` wrapper the Hyprland version defaults to:
  # that requires the compositor to be running as a UWSM-managed session
  # (your Hyprland one is, via `hyprland-uwsm`/`withUWSM`), and this niri
  # session isn't set up that way, so `uwsm app --` just fails silently.
  home.file.".local/scripts/niri/launch-or-focus.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      if (($# == 0)); then
        echo "Usage: launch-or-focus [window-pattern] [launch-command]"
        exit 1
      fi

      WINDOW_PATTERN="$1"
      LAUNCH_COMMAND="''${2:-$WINDOW_PATTERN}"
      WINDOW_ID=$(niri msg -j windows | jq -r --arg p "$WINDOW_PATTERN" \
        '.[] | select(((.app_id // "") + " " + (.title // "")) | test($p; "i")) | .id' \
        | head -n1)

      if [[ -n $WINDOW_ID ]]; then
        niri msg action focus-window --id "$WINDOW_ID"
      else
        eval exec $LAUNCH_COMMAND
      fi
    '';
  };

  # niri-native replacement for ~/.local/scripts/hypr/launch-browser.sh -
  # same default-browser/private-window detection, minus the `uwsm app --`
  # wrapper (see above).
  home.file.".local/scripts/niri/launch-browser.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      default_browser=$(xdg-settings get default-web-browser)
      browser_exec=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' {~/.local,~/.nix-profile,/usr,/run/current-system/sw}/share/applications/$default_browser 2>/dev/null | head -1)

      if [[ $browser_exec =~ (firefox|zen|librewolf|floorp) ]]; then
        private_flag="--private-window"
      else
        private_flag="--incognito"
      fi

      exec setsid "$browser_exec" "--disable-features=WaylandWpColorManagerV1" "''${@/--private/$private_flag}"
    '';
  };

  # Mod+Shift+J (binds.nix) - toggles the focused column between 1/3 and
  # 2/3 width. There's no niri action for this directly: `switch-preset-column-width`
  # only cycles through the single global `layout.preset-column-widths` list,
  # which Mod+J already uses for the full/half toggle. So this compares the
  # focused window's current tile width against half its output's width to
  # decide which third to jump to.
  home.file.".local/scripts/niri/toggle-column-width-thirds.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      tile_width=$(niri msg -j focused-window | jq -r '.layout.tile_size[0] // empty')
      out_width=$(niri msg -j focused-output | jq -r '.logical.width // empty')

      if [[ -z $tile_width || -z $out_width ]]; then
        exit 0
      fi

      if awk -v t="$tile_width" -v w="$out_width" 'BEGIN{exit !(t < w/2)}'; then
        niri msg action set-column-width "66.6667%"
      else
        niri msg action set-column-width "33.3333%"
      fi
    '';
  };
}
