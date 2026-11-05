{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # nixpkgs' hyprspace predates Hyprland 0.56 and fails to build; use the
  # commit upstream's hyprpm.toml pins for 0.56. Bump alongside Hyprland.
  hyprspace = pkgs.hyprlandPlugins.hyprspace.overrideAttrs {
    version = "0-unstable-2026-07-25";
    src = pkgs.fetchFromGitHub {
      owner = "KZDKM";
      repo = "Hyprspace";
      rev = "96a3b958a05a8942d26a5ec510f60217d63a7dce";
      hash = "sha256-UJyjUHSApvk6DcnrbxzmU4meTZRQeBldqkRoorK2DN8=";
    };
  };
in {
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

      -- Loaded here because extraLuaFiles run before settings.config, so
      -- plugin.overview options set there are already registered.
      hl.plugin.load("${hyprspace}/lib/libhyprspace.so")

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
      -- Toggle a dim red night filter, like niri's gammastep bind. Hyprland
      -- exposes no gamma ramps to gammastep, so drive the hyprsunset daemon
      -- (started in autostart.nix) over IPC; gamma doubles as the on/off state.
      bind("N", exec("if [ \"$(hyprctl hyprsunset gamma)\" = 100 ]; then"
        .. " hyprctl hyprsunset temperature 1000; hyprctl hyprsunset gamma 40;"
        .. " else hyprctl hyprsunset gamma 100; hyprctl hyprsunset identity; fi"))
      -- Like niri's screenshot UI: freezes the focused monitor into a fullscreen
      -- satty window with the crop tool active; Enter saves + copies, Escape cancels.
      -- satty can't toggle the pointer live, so CTRL picks the variant with it.
      local function screenshot(withCursor)
        return function()
          local mon = hl.get_active_monitor()
          if mon == nil then return end
          hl.exec_cmd("grim " .. (withCursor and "-c " or "") .. "-o " .. mon.name .. " - | satty --filename -"
            .. " --fullscreen --initial-tool crop --copy-command wl-copy"
            .. " --actions-on-enter save-to-clipboard,save-to-file,exit"
            .. " --output-filename '~/Pictures/Hyprshot/Screenshot from %Y-%m-%d %H-%M-%S.png'")
        end
      end
      bind("SHIFT + S", screenshot(false))
      bind("CTRL + SHIFT + S", screenshot(true))
      bind("F", hl.dsp.window.fullscreen())

      -- Scrolling layout, mirroring the niri binds (home/niri/binds.nix).
      -- Toggle column between half and full width (scrolling.explicit_column_widths).
      bind("J", hl.dsp.layout("colresize +conf"))
      -- Toggle column between 1/3 and 2/3 width.
      bind("SHIFT + J", function()
        local w = hl.get_active_window()
        if w == nil or w.monitor == nil then return end
        local width = type(w.size) == "table" and (w.size.x or w.size[1]) or w.size
        local monWidth = w.monitor.width / w.monitor.scale
        hl.dispatch(hl.dsp.layout(width < monWidth / 2 and "colresize 0.667" or "colresize 0.333"))
      end)

      -- Workspace overview, like niri's SUPER+SPACE (hyprspace, loaded above).
      -- Plugin dispatchers live under hl.plugin.<name> and run when called;
      -- `hyprctl dispatch overview:...` no longer works with a Lua config.
      bind("space", function() hl.plugin.overview.toggle() end)

      bind("CTRL + left", hl.dsp.layout("swapcol l"))
      bind("CTRL + right", hl.dsp.layout("swapcol r"))
      bind("CTRL + f", hl.dsp.layout("fit expand"))

      -- Merge the window into the neighbouring column, or pop it back out.
      bind("bracketleft", hl.dsp.layout("consume_or_expel prev"))
      bind("bracketright", hl.dsp.layout("consume_or_expel next"))

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
