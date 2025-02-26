{ inputs, pkgs, ... }:

{
  home = {
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

  programs.zsh = {
    enable = true;

    shellAliases = {
      ll = "ls -l";
      cls = "clear";
      cat = "bat";
      s = "kitten ssh";

      update = "nixos-rebuild switch --use-remote-sudo --flake /home/bennet/system#bennet";
      config = "nvim /home/bennet/system/flake.nix";
      home-update = "/home/bennet/system/home.sh";
      home-config = "nvim /home/bennet/system/home/bennet.nix";
      changewp = "swww img";
    };

    initExtra = ''
      export PATH="/home/bennet/.nix-profile/bin:$PATH"
      # Set the directory we want to store zinit and plugins
      # ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"

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
      eval "$(direnv hook zsh)"

      # remove dulicate PATH Varaibles
      export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!a[$0]++' | tr '\n' ':')
    '';
  };

  programs.kitty = {
    enable = true;
    shellIntegration.mode = "zsh";
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      dynamic_background_opacity = true;
      background_opacity = "0.75";

      # custom gruvbox theme with no bg and fg
      selection_foreground = "#ebdbb2";
      selection_background = "#d65d0e";
      color0 = "#3c3836";
      color1 = "#cc241d";
      color2 = "#98971a";
      color3 = "#d79921";
      color4 = "#458588";
      color5 = "#b16286";
      color6 = "#689d6a";
      color7 = "#a89984";
      color8 = "#928374";
      color9 = "#fb4934";
      color10 = "#b8bb26";
      color11 = "#fabd2f";
      color12 = "#83a598";
      color13 = "#d3869b";
      color14 = "#8ec07c";
      color15 = "#fbf1c7";
      cursor = "#bdae93";
      cursor_text_color = "#665c54";
      url_color = "#458588";
    };
  };

  # services.mako = {
  #   enable = true;
  #   sort = "-time";
  #   layer = "overlay";
  #   backgroundColor = "#2e3440";
  #   width = 300;
  #   height = 110;
  #   borderSize = 2;
  #   borderColor = "#33ccff";
  #   borderRadius = 15;
  #   maxIconSize = 64;
  #   defaultTimeout = 4000;
  #   ignoreTimeout = true;
  #   font = "monospace 14";
  #
  #   extraConfig = ''
  #     [urgency=low]
  #     border-color=#33ccff
  #
  #     [urgency=normal]
  #     border-color=#d08770
  #
  #     [urgency=high]
  #     border-color=#bf616a
  #     default-timeout=0
  #
  #     [category=mdp]
  #     default-timeout=2000
  #     group-by=category
  #   '';
  # };

  services.swaync = {
    enable = true;
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

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
}
