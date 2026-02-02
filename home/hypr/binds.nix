{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    settings = {
      "$terminal" = "kitty";
      "$fileManager" = "nemo";
      "$menu" = "rofi -show drun";
      # "$menu" = "wofi";
      "$mainMod" = "SUPER";
      "$browser" = "~/.local/scripts/hypr/launch-browser.sh";
      "$launch-or-focus" = "~/.local/scripts/hypr/launch-or-focus.sh";
      "$ipc" = "noctalia-shell ipc call";

      bind = [
        "$mainMod, M, exec, $launch-or-focus spotify"
        "$mainMod, O, exec, $launch-or-focus obsidian 'uwsm app -- obsidian -disable-gpu --enable-wayland-ime'"
        "$mainMod, slash, exec, $launch-or-focus keepassxc"
        "$mainMod, G, exec, $launch-or-focus signal 'uwsm app -- signal-desktop'"

        # noctalia-shell
        "$mainMod, R, exec, $ipc launcher toggle"
        "$mainMod, S, exec, $ipc controlCenter toggle"
        "$mainMod, comma, exec, $ipc settings toggle"
        "$mainMod, L, exec, $ipc lockScreen lock"

        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating"
        # "$mainMod, R, exec, ~/.config/rofi/launchers/type-1/launcher.sh"
        # "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"
        # "$mainMod, L, exec, hyprlock"
        ",switch:Lid Switch, exec, hyprlock"
        "$mainMod SHIFT, S, exec, hyprshot -m region -o /home/bennet/Pictures/Hyprshot"
        "$mainMod, F, fullscreen"

        "$mainMod Control, left, layoutmsg, move -col"
        "$mainMod Control, right, layoutmsg, move +col"
        "$mainMod Control, f, layoutmsg, fit active"

        "$mainMod SHIFT, R, exec, bash ~/.local/scripts/hypr/restart_bar.sh"
        "$mainMod SHIFT, W, exec, bash ~/.local/scripts/hypr/restart_walker.sh"
        # "$mainMod, S, exec, bash ~/.local/scripts/rofi/chars.sh"

        "$mainMod SHIFT, C, forcekillactive"

        "CTRL_ALT, delete, exec, bash ~/.config/rofi/powermenu/type-6/powermenu.sh"

        "$mainMod, B, exec, $browser"
        "$mainMod SHIFT, B, exec, $browser --private"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod SHIFT, left, swapwindow, l"
        "$mainMod SHIFT, right, swapwindow, r"
        "$mainMod SHIFT, up, swapwindow, u"
        "$mainMod SHIFT, down, swapwindow, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, code:20, resizeactive, -100 0" # - key
        "$mainMod, code:21, resizeactive, 100 0" # = key
        "$mainMod SHIFT, code:20, resizeactive, 0 -100" # - key
        "$mainMod SHIFT, code:21, resizeactive, 0 100" # = key

        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +1%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -1%"

        "$mainMod, K, exec, rofi -show calc -modi calc -no-show-match -no-sort -no-persist-history"
        "$mainMod, period, exec, rofi -modi emoji -show emoji"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle" # Toggle Mute
        ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl -i kdeconnect play-pause" # Play/Pause Song
        ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl -i kdeconnect next" # Next Song
        ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl -i kdeconnect previous" # Previous Song
        ",switch:Lid Switch, exec, ${pkgs.hyprlock}/bin/hyprlock" # Lock when closing Lid
      ];

      bindle = [
        ",XF86AudioRaiseVolume, exec, sound-up" # Sound Up
        ",XF86AudioLowerVolume, exec, sound-down" # Sound Down
        ",XF86MonBrightnessUp, exec, brightness-up" # Brightness Up
        ",XF86MonBrightnessDown, exec, brightness-down" # Brightness Down
      ];
    };
  };
}
