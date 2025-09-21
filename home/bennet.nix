{
  inputs,
  pkgs,
  lib,
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

  imports =
    import ./hypr;

  stylix = {
    enable = true;
    targets = {
      spicetify.enable = false;
    };
  };

  programs = {
    quickshell = {
      enable = true;
      systemd.enable = false;
    };
    zellij = {
      enable = true;
      settings = {
        pane_frames = false;
        tab_bar = false;
        keybinds = {
          unbind = [
            "Ctrl p" # interferes with nvim binding
            "Ctrl n" # interferes with nvim binding
            "Ctrl o" # interferes with opencode binding
            "Ctrl t" # interferes with opencode binding
          ];
        };
      };
    };
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

        def web2app [
          app_name: string,
          app_url: string,
          icon_url: string
        ] {
          let icon_dir = $"($nu.home-path)/.local/share/applications/icons"
          let desktop_file = $"($nu.home-path)/.local/share/applications/($app_name).desktop"
          let icon_path = $"($icon_dir)/($app_name).png"

          mkdir $icon_dir

          let curl_result = (curl -sL $icon_url -o $icon_path)

          let desktop_content = [
            "[Desktop Entry]"
            "Version=1.0"
            $"Name=($app_name)"
            $"Comment=($app_name)"
            $"Exec=brave --new-window --ozone-platform=wayland --app=\"($app_url)\" --name=\"($app_name)\" --class=\"($app_name)\""
            "Terminal=false"
            "Type=Application"
            $"Icon=($icon_path)"
            "StartupNotify=true"
          ] | str join "\n"

          $desktop_content | save --force $desktop_file
          chmod +x $desktop_file
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
        format = lib.concatStrings [
          "[](orange)"
          "$os"
          "$username"
          "[](bg:yellow fg:orange)"
          "$directory"
          "[](fg:yellow bg:base15)"
          "$git_branch"
          "$git_status"
          "[](fg:base15 bg:blue)"
          "$c"
          "$cpp"
          "$rust"
          "$golang"
          "$nodejs"
          "$php"
          "$java"
          "$kotlin"
          "$haskell"
          "$python"
          "[](fg:blue bg:base03)"
          "$nix_shell"
          "$docker_context"
          "$conda"
          "$pixi"
          "[](fg:base03 bg:base01)"
          "$time"
          "[ ](fg:base01)"
          "$line_break$character"
        ];
        os = {
          disabled = false;
          style = "bg:orange fg:base01";
          symbols = {
            NixOS = "󱄅";
          };
        };
        username = {
          show_always = true;
          style_user = "bg:orange fg:base01";
          style_root = "bg:orange fg:base01";
          format = "[ $user ]($style)";
        };
        directory = {
          style = "fg:bright-white bg:yellow";
          format = "[ $path ]($style)";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
          };
        };
        git_branch = {
          symbol = "";
          style = "bg:base15";
          format = "[[ $symbol $branch ](fg:bright-white bg:base15)]($style)";
        };
        git_status = {
          style = "bg:base15";
          format = "[[($all_status$ahead_behind )](fg:bright-white bg:base15)]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        cpp = {
          symbol = " ";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        golang = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        php = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        java = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        kotlin = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        haskell = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        python = {
          symbol = "";
          style = "bg:blue";
          format = "[[ $symbol( $version) ](fg:bright-white bg:blue)]($style)";
        };
        docker_context = {
          symbol = "";
          style = "bg:base03";
          format = "[[ $symbol( $context) ](fg:#83a598 bg:base03)]($style)";
        };
        nix_shell = {
          symbol = "󱄅";
          style = "bg:base03";
          format = "[via $symbol $state (($name))]($style)";
        };
        conda = {
          style = "bg:base03";
          format = "[[ $symbol( $environment) ](fg:#83a598 bg:base03)]($style)";
        };
        pixi = {
          style = "bg:base03";
          format = "[[ $symbol( $version)( $environment) ](fg:bright-white bg:base03)]($style)";
        };
        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:base01";
          format = "[[  $time ](fg:bright-white bg:base01)]($style)";
        };
        line_break = false;
        character = {
          disabled = false;
          success_symbol = "[](bold fg:green)";
          error_symbol = "[](bold fg:red)";
          vimcmd_symbol = "[](bold fg:green)";
          vimcmd_replace_one_symbol = "[](bold fg:purple)";
          vimcmd_replace_symbol = "[](bold fg:purple)";
          vimcmd_visual_symbol = "[](bold fg:yellow)";
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
        # {
        #   plugin = tmuxPlugins.catppuccin;
        #   extraConfig = "set -g @catppuccin_flavor 'mocha'"; # latte, frappe, macchiato or mocha
        # }
        {
          plugin = tmuxPlugins.sensible;
        }
        {
          plugin = tmuxPlugins.yank;
        }
        {
          plugin = tmuxPlugins.vim-tmux-navigator;
        }
        {
          plugin = tmuxPlugins.logging;
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
    settings = {
      monitor = [
        "DP-1,3440x1440@144,0x-450,1"
        "DP-2,1920x1080@75,3440x0,1"
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
