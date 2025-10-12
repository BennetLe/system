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

  imports = import ./hypr;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Tela-light";
      package = pkgs.tela-icon-theme;
    };
  };

  programs = {
    hyprlock = {
      settings = {
        auth = {
          fingerprint = {
            enable = true;
          };
        };
      };
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

        update = "nixos-rebuild switch --sudo --flake /home/bennet/system#framework";
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

    zsh = {
      enable = true;

      shellAliases = {
        ls = "eza";
        ll = "ls -l";
        cls = "clear";
        cat = "bat";
        s = "kitten ssh";

        update = "nixos-rebuild switch --use-remote-sudo --flake /home/bennet/system#framework";
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
        eval "$(zoxide init --cmd cd zsh)"

        # remove dulicate PATH Varaibles
        export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!a[$0]++' | tr '\n' ':')
      '';
    };
    kitty = {
      enable = true;
      shellIntegration.mode = "zsh";
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
      font = lib.mkForce "JetBrainsMono Nerd Font Mono 16";
      yoffset = 0;
      xoffset = 0;
      location = "center";
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
      nix-direnv.enable = true;
    };
  };

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          before_sleep_cmd = "loginctl lock-session";
          lock_cmd = "pidof hyprlock || hyperlock";
        };

        listener = [
          {
            timeout = 600; # 10 min time out
            on-timeout = "hyperlock";
          }
          {
            timeout = 720; # 12 min time out
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 900; # 15 min time out
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
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
        "eDP-1,2256x1504@60,0x0,1"
        ", preferred, auto, 1, mirror, eDP-1"
      ];

      workspace = [
        "1,monitor:eDP-1"
        "2,monitor:eDP-1"
        "3,monitor:eDP-1"
        "4,monitor:eDP-1"
        "5,monitor:eDP-1"
        "6,monitor:eDP-1"
        "7,monitor:eDP-1"
        "8,monitor:eDP-1"
        "9,monitor:eDP-1"
        "10,monitor:eDP-1"
      ];
    };
  };

  programs.home-manager.enable = true;
}
