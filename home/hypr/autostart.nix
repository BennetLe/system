{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    extraLuaFiles.autostart = ''
      hl.on("hyprland.start", function()
        hl.dispatch(hl.dsp.focus({ workspace = 1 }))
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("systemctl --user start hyprpolkitagent")
        -- hl.exec_cmd("hyprctl setcursors Sweet-cursor 24")
        hl.exec_cmd("~/.local/scripts/hypr/screensharing.sh")
        hl.exec_cmd("~/.local/scripts/hypr/start.sh")
        hl.exec_cmd("kdeconnect-indicator")
        hl.exec_cmd("noctalia")
        hl.exec_cmd("hyprsunset")
        hl.exec_cmd("hyprlauncher -d")
        hl.exec_cmd("uwsm app -- tailscale systray")
      end)
    '';
  };
}
