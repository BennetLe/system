{
  inputs,
  pkgs,
  ...
}: {
  home = {
    username = "bennet";
    homeDirectory = "/home/bennet";
    stateVersion = "24.05";
    packages = [
    ];

    file = {
    };

    sessionVariables = {
      EDITOR = "vim";
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
      PATH = "/home/bennet/.cargo/bin:$PATH";
      TERMINAL = "kitty";
      HYPRSHOT_DIR = "/home/bennet/Pictures/Hyprshot";
    };
  };

  # imports = [inputs.hyprpanel.homeManagerModules.hyprpanel];

  stylix = {
    targets = {
    };
  };

  programs = {
    eza = {
      enable = true;
      enableNushellIntegration = false;
      git = true;
      icons = "auto";
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
    nushell = {
      enable = true;
      # configFile.source = ./config.nu;
      extraConfig = ''
         let carapace_completer = {|spans|
            carapace $spans.0 nushell ...$spans | from json
          }
          $env.config = {
            show_banner: false,
            completions: {
            case_sensitive: false # case-sensitive completions
            quick: true    # set to false to prevent auto-selecting completions
            partial: true    # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
              # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true
              # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100
              completer: $carapace_completer # check 'carapace_completer'
            }
          }
        }
        $env.PATH = ($env.PATH |
        split row (char esep) |
        prepend /home/myuser/.apps |
        append /usr/bin/env
        )

        def --env y [...args] {
          let tmp = (mktemp -t "yazi-cwd.XXXXXX")
          yazi ...$args --cwd-file $tmp
          let cwd = (open $tmp)
          if $cwd != "" and $cwd != $env.PWD {
            cd $cwd
          }
          rm -fp $tmp
        }
      '';
      envFile = {
        text = ''
          $env.TRANSIENT_PROMPT_COMMAND = ^starship module character
        '';
      };
      shellAliases = {
        # ls = "eza";
        ll = "ls -l";
        cls = "clear";
        s = "kitten ssh";

        cat = "bat";
        cd = "z";

        update = "nixos-rebuild switch --sudo --flake /home/bennet/system#bennet";
        config = "nvim /home/bennet/system/flake.nix";
        changewp = "swww img";

        brave = "brave --password-store=gnome";
      };
    };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;
      enableTransience = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };

    hyprpanel = {
      enable = true;
      # hyprland.enable = true;
      # overwrite.enable = true;

      settings = {
        layout = {
          "bar.layouts" = {
            "*" = {
              left = ["dashboard" "workspaces" "windowtitle"];
              middle = ["media"];
              right = ["volume" "network" "systray" "clock" "notifications"];
            };
          };
        };

        bar = {
          launcher.autoDetectIcon = true;
          systray.ignore = [
            "blueman"
            "nm-applet"
            "Xwayland Video Bridge_pipewireToXProxy"
            "spotify-client"
          ];
          clock = {
            format = "%a %d %b %H:%M";
          };
          workspaces = {
            show_numbered = true;
            numbered_active_indicator = "color";
          };
          battery = {
            label = false;
          };
          network = {
            label = false;
          };
        };

        theme = {
          bar = {
            buttons = {
              enableBorders = true;
              workspaces.smartHighlight = true;
            };
            opacity = 75;
            scaling = 75;
          };
        };

        menus = {
          clock = {
            weather.enabled = false;
            time = {
              hideSeconds = true;
              military = true;
            };
          };
          dashboard = {
            powermenu.avatar.image = "/home/bennet/Pictures/profie pic.jpg";
          };
        };
      };
    };
    zsh = {
      enable = true;

      shellAliases = {
        ls = "eza";
        ll = "ls -l";
        cls = "clear";
        cat = "bat";
        s = "kitten ssh";

        update = "nixos-rebuild switch --use-remote-sudo --flake /home/bennet/system#bennet";
        config = "nvim /home/bennet/system/flake.nix";
        changewp = "swww img";

        brave = "brave --password-store=gnome";
      };

      initContent = ''
        export PATH="/home/bennet/.nix-profile/bin:$PATH"
        # Set the directory we want to store zinit and plugins
        # ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"

        export PATH="''${HOME}/go/bin:$PATH"

        ZIM_HOME=~/.zim

        # Download Zinit, if it's not there yet
        # if [ ! -d "$ZINIT_HOME" ]; then
        #     mkdir -p "$(dirname $ZINIT_HOME)"
        #     git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
        # fi

        # Download zimfw plugin manager if missing.
        if [[ ! -e ''${ZIM_HOME}/zimfw.zsh ]]; then
          curl -fsSL --create-dirs -o ''${ZIM_HOME}/zimfw.zsh \
              https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        fi

        # Install missing modules, and update ''${ZIM_HOME}/init.zsh if missing or outdated.
        if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZDOTDIR:-''${HOME}}/.zimrc ]]; then
          source ''${ZIM_HOME}/zimfw.zsh init -q
        fi

        # Initialize modules.
        source ''${ZIM_HOME}/init.zsh

        # Source/Load zinit
        # source "''${ZINIT_HOME}/zinit.zsh"

        # Prompt
        eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

        # Add in zsh plugins
        # zinit light zsh-users/zsh-syntax-highlighting
        # zinit light zsh-users/zsh-completions
        # zinit light zsh-users/zsh-autosuggestions
        # zinit light Aloxaf/fzf-tab

        # Add in snippets
        # zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'
        # zinit snippet 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh'

        # Load completions
        # autoload -Uz compinit && compinit

        # zinit cdreplay -q

        # Keybindings
        bindkey "^y" autosuggest-accept
        bindkey '^n' history-search-backward
        bindkey '^p' history-search-forward
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        unalias run-help 2>/dev/null
        autoload -U run-help

        HISTSIZE=10000
        SAVEHIST=$HISTSIZE
        HISTFILE=~/.zsh_history
        HISTDUP=erase
        setopt appendhistory
        setopt sharehistory
        setopt hist_ignore_space
        setopt hist_ignore_all_dups
        setopt hist_save_no_dups
        setopt hist_ignore_dups
        setopt hist_find_no_dups

        # Completion styling
        # zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        # zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        # zstyle ':completion:*' menu no
        # zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        # zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

        # Shell integration
        eval "$(fzf --zsh)"
        # eval "$(zoxide init --cmd cd zsh)"

        # remove dulicate PATH Varaibles
        export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!a[$0]++' | tr '\n' ':')

        function y() {
         local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
         yazi "$@" --cwd-file="$tmp"
         if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
         fi
         rm -f -- "$tmp"
        }

        function rg() {
          tmp="$(mktemp)"
          ranger --choosedir="$tmp" "$@"
          if [ -f "$tmp" ]; then
            dir="$(cat "$tmp")"
            rm -f "$tmp"
            [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
          fi
        }
      '';
    };

    kitty = {
      enable = true;
      # shellIntegration.mode = "zsh";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        dynamic_background_opacity = true;
      };
    };

    hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 1;
        };

        background = {
          path = "~/Wallpapers/Gruvbox/ign-waifu.png";
          blur_size = 4;
          blur_passes = 1;
          noise = 0.0117;
          contrast = 1.3;
          brightness = 0.5;
          vibrancy = 0.21;
          vibrancy_darkness = 0.5;
        };

        input-field = {
          size = "250, 50";
          outline_thickness = 0;
          dots_size = 0.2;
          dots_spacing = 0.15;
          dots_center = true;
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          position = "0, 100";
          halign = "center";
          valign = "bottom";
        };

        label = [
          # Date
          {
            monitor = "";
            text = ''cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"'';
            color = "rgba(184, 212, 224, 0.6)";
            font_size = 28;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "0, -420";
            halign = "center";
            valign = "top";
          }
          # Time
          {
            monitor = "";
            text = ''cmd[update:1000] echo -e "$(date +"%H":"%M")"'';
            color = "rgba(184, 212, 224, 0.6)";
            font_size = 130;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "0, -220";
            halign = "center";
            valign = "top";
          }
          # User
          {
            monitor = "";
            text = ''$USER'';
            color = "rgb(126, 247, 138)";
            font_size = 16;
            font_family = "Inter Display Medium";
            position = "0, 70";
            halign = "center";
            valign = "bottom";
          }
          # Uptime
          {
            monitor = "";
            text = ''cmd[update:60000] echo "<b> "$(uptime -p || $Scripts/UptimeNixOS.sh)" </b>"'';
            color = "rgba(184, 212, 224, 0.4)";
            font_size = 12;
            font_family = "JetBrains Mono Nerd Font Mono ExtraBold";
            position = "5, 5";
            halign = "right";
            valign = "bottom";
          }
          # # Music Player Info # #
          # PLAYER TITLE
          {
            monitor = "DP-1";
            text = ''cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:title }}" 2>/dev/null | cut -c1-50'';
            color = "rgba(184, 212, 224, 0.8)";
            font_size = 14;
            font_family = "Inter Display Medium";
            position = "180, 120";
            halign = "left";
            valign = "bottom";
          }
          # PLAYER ARTIST
          {
            monitor = "DP-1";
            text = ''cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:artist }}" 2>/dev/null | cut -c1-50)"'';
            color = "rgba(184, 212, 224, 0.8)";
            font_size = 14;
            font_family = "Inter Display Medium";
            position = "180, 80";
            halign = "left";
            valign = "bottom";
          }
          # PLAYER ALBUM
          {
            monitor = "DP-1";
            text = ''cmd[update:1000] echo "$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null | cut -c1-50)"'';
            color = "rgba(184, 212, 224, 0.8)";
            font_size = 14;
            font_family = "Inter Display Medium";
            position = "180, 40";
            halign = "left";
            valign = "bottom";
          }
        ];
      };
    };

    tmux = {
      enable = true;
      prefix = "C-Space";

      # shell = "\${pkgs.zsh}/bin/zsh";
      mouse = true;
      clock24 = true;
      keyMode = "vi";
      shortcut = "Space";
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"

        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        bind -n M-H previous-window
        bind -n M-L next-window

        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -r i run-shell "tmux neww ~/.local/scripts/tmux-cht.sh"

        unbind-key -n C-h
        unbind-key -n C-j
        unbind-key -n C-k
        unbind-key -n C-l
      '';

      plugins = with pkgs; [
        # {
        #   plugin = tmuxPlugins.gruvbox;
        #   extraConfig = "set -g @tmux-gruvbox 'dark'";
        # }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = "set -g @catppuccin_flavor 'mocha'"; # latte, frappe, macchiato or mocha
        }
        {
          plugin = tmuxPlugins.sensible;
        }
        {
          plugin = tmuxPlugins.yank;
        }
        {
          plugin = tmuxPlugins.vim-tmux-navigator;
        }
      ];
    };

    rofi = {
      enable = true;
      yoffset = 0;
      xoffset = 0;
      location = "center";
      extraConfig = {
        modi = "drun,emoji,window,ssh";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
      };
      plugins = with pkgs; [
        rofi-emoji
        rofi-calc
      ];
    };

    wofi = {
      enable = true;
      settings = {
        height = "40%";
        hide_scroll = true;
        insensitive = true;
        location = 2;
        matching = "fuzzy";
        mode = "drun";
        term = "kitty";
        width = "40%";
        yoffset = 300;
        line_wrap = "word";
        single_click = true;
        allow_images = true;
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };

  services = {
    swaync = {
      enable = false;
      settings = {
        timeout = 5;
        timeout-low = 2;
        timeout-critical = 0;
      };
      style = ''
        /* Low priority notifications */
        .notification.low {
            border-left: 4px solid #8ec07c; /* Green accent */
            background-color: #1d2021;      /* Optional background */
        }

        /* Normal priority notifications */
        .notification.normal {
            border-left: 4px solid #d79921; /* Yellow accent */
            background-color: #282828;      /* Optional background */
        }

        /* Critical priority notifications */
        .notification.critical {
            border-left: 4px solid #fb4934; /* Red accent */
            background-color: #3c3836;      /* Optional background */
        }
      '';
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hyprscrolling
    ];
    settings = {
      "$terminal" = "kitty";
      "$fileManager" = "nemo";
      "$menu" = "rofi -show drun -show-icons";
      # "$menu" = "wofi";
      "$mainMod" = "SUPER";

      monitor = [
        "DP-1,3440x1440@144,0x-450,1"
        "DP-2,1920x1080@75,3440x0,1"
      ];

      plugin = {
        hyprscrolling = {
          fullscreen_on_one_column = true;
          focus_fit_method = 1;
        };
      };

      exec-once = [
        "hyprctl dispatch workspace 1 &"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        # "hyprctl setcursors Sweet-cursor 24"
        "~/.local/scripts/hypr/screensharing.sh"
        "~/.local/scripts/hypr/start.sh"
        "kdeconnect-indicator"
      ];

      env = [
        # "XCURSOR_SIZE,24"
        # "HYPRCURSOR_SIZE,24"
        # "HYPRCURSOR_THEME,Sweet-cursors"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "MOZ_ENABLE_WAYLAND,1"
        "ANKI_WAYLAND,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM=wayland,xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 1;
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
          range = 4;
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
        kb_options = ["compose:caps"];
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

      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating"
        # "$mainMod, R, exec, ~/.config/rofi/launchers/type-1/launcher.sh"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"
        "$mainMod, L, exec, hyprlock"
        ",switch:Lid Switch, exec, hyprlock"
        "SUPER_SHIFT, S, exec, hyprshot -m region -o /home/bennet/Pictures/Hyprshot"
        "$mainMod, F, fullscreen"

        "$mainMod Control, left, layoutmsg, move -col"
        "$mainMod Control, right, layoutmsg, move +col"
        "$mainMod Control, f, layoutmsg, fit active"

        "SUPER_SHIFT, R, exec, pkill waybar && waybar &"

        "SUPER_SHIFT, C, forcekillactive"

        "CTRL_ALT, delete, exec, bash ~/.config/rofi/powermenu/type-6/powermenu.sh"

        "$mainMod, B, exec, brave --password-store=gnome"

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

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "opacity 1.0, fullscreen:(1)"
        "opacity 0.9, class:(kitty)"
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

      workspace = [
        "1,monitor:DP-1"
        "2,monitor:DP-1"
        "3,monitor:DP-1"
        "4,monitor:DP-1"
        "5,monitor:DP-2"
        "6,monitor:DP-2"
        "7,monitor:DP-2"
        "8,monitor:DP-2"
        "9,monitor:DP-2"
        "10,monitor:DP-2"
      ];
    };
  };

  programs.home-manager = {
    enable = true;
  };
}
