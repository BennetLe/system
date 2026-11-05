{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    # Plain Lua (auto-required from hyprland.lua) instead of `settings.bind`
    # entries - lets the workspace binds be a loop and avoids wrapping every
    # dispatcher in mkLuaInline.
    extraLuaFiles.binds = ''
      local mainMod = "SUPER"
      local terminal = "kitty"
      local fileManager = "nemo"
      local browser = "~/.local/scripts/hypr/launch-browser.sh"
      local launchOrFocus = "~/.local/scripts/hypr/launch-or-focus.sh"
      local ipc = "noctalia msg"
      local playerctl = "${pkgs.playerctl}/bin/playerctl -i kdeconnect"

      local function bind(keys, dispatcher, opts)
        hl.bind(mainMod .. " + " .. keys, dispatcher, opts)
      end
      local exec = hl.dsp.exec_cmd

      bind("M", exec(launchOrFocus .. " spotify"))
      bind("O", exec(launchOrFocus .. " obsidian 'uwsm app -- obsidian -disable-gpu --enable-wayland-ime'"))
      bind("slash", exec(launchOrFocus .. " keepassxc"))
      bind("G", exec(launchOrFocus .. " signal 'uwsm app -- signal-desktop'"))

      -- noctalia-shell
      bind("R", exec(ipc .. " panel-toggle launcher"))
      bind("S", exec(ipc .. " panel-toggle control-center"))
      bind("comma", exec(ipc .. " settings-toggle"))
      bind("L", exec(ipc .. " session lock"))

      bind("Q", exec(terminal))
      bind("C", hl.dsp.window.close())
      bind("SHIFT + C", hl.dsp.window.kill())
      bind("E", exec(fileManager))
      bind("V", hl.dsp.window.float({ action = "toggle" }))
      bind("P", hl.dsp.window.pseudo())
      bind("J", hl.dsp.layout("togglesplit"))
      bind("SHIFT + S", exec("hyprshot -m region -o /home/bennet/Pictures/Hyprshot"))
      bind("F", hl.dsp.window.fullscreen())

      bind("CTRL + left", hl.dsp.layout("move -col"))
      bind("CTRL + right", hl.dsp.layout("move +col"))
      bind("CTRL + f", hl.dsp.layout("fit active"))

      bind("SHIFT + R", exec("bash ~/.local/scripts/hypr/restart_bar.sh"))
      bind("SHIFT + W", exec("bash ~/.local/scripts/hypr/restart_walker.sh"))

      hl.bind("CTRL + ALT + delete", exec("bash ~/.config/rofi/powermenu/type-6/powermenu.sh"))

      bind("B", exec(browser))
      bind("SHIFT + B", exec(browser .. " --private"))

      for _, dir in ipairs({ "left", "right", "up", "down" }) do
        bind(dir, hl.dsp.focus({ direction = dir }))
        bind("SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
      end

      for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        bind(key, hl.dsp.focus({ workspace = i }))
        bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      bind("code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true })) -- - key
      bind("code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true })) -- = key
      bind("SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true })) -- - key
      bind("SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100, relative = true })) -- = key

      bind("K", exec("rofi -show calc -modi calc -no-show-match -no-sort -no-persist-history"))
      bind("period", exec("rofi -modi emoji -show emoji"))

      hl.bind("PAUSE", exec("wl-freeze -a"))

      bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
      bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

      local locked = { locked = true }
      hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_SINK@ toggle"), locked)
      hl.bind("XF86AudioPlay", exec(playerctl .. " play-pause"), locked)
      hl.bind("XF86AudioNext", exec(playerctl .. " next"), locked)
      hl.bind("XF86AudioPrev", exec(playerctl .. " previous"), locked)
      hl.bind("switch:Lid Switch", exec(ipc .. " session lock"), locked) -- Lock when closing Lid

      local lockedRepeat = { locked = true, repeating = true }
      hl.bind("XF86AudioRaiseVolume", exec(ipc .. " volume-up 1"), lockedRepeat)
      hl.bind("XF86AudioLowerVolume", exec(ipc .. " volume-down 1"), lockedRepeat)
      hl.bind("XF86MonBrightnessUp", exec(ipc .. " brightness-up"), lockedRepeat)
      hl.bind("XF86MonBrightnessDown", exec(ipc .. " brightness-down"), lockedRepeat)
    '';
  };
}
