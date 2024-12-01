{ inputs, pkgs, ... }:

{
  home = {
    packages = [
    ];

    file = {
    };

    sessionVariables = {
      EDITOR = "nvim";
      XDG_DATA_DIRS= "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
      PATH = "/home/bennet/.cargo/bin:$PATH";
      TERMINAL = "kitty";
      HYPRSHOT_DIR = "/home/bennet/Pictures/Hyprshot";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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
      # Set the directory we want to store zinit and plugins
      ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"

      # Download Zinit, if it's not there yet
      if [ ! -d "$ZINIT_HOME" ]; then
          mkdir -p "$(dirname $ZINIT_HOME)"
          git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
      fi

      # Source/Load zinit
      source "''${ZINIT_HOME}/zinit.zsh"

      # Prompt
      eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
    '';
  };

  programs.kitty = {
    enable = true;
    settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        dynamic_background_opacity = true;
        background_opacity = "0.75";
      };
  };

  services.mako = {
    enable = true;
    sort = "-time";
    layer = "overlay";
    backgroundColor = "#2e3440";
    width = 300;
    height = 110;
    borderSize = 2;
    borderColor = "#33ccff";
    borderRadius = 15;
    maxIconSize = 64;
    defaultTimeout = 4000;
    ignoreTimeout = true;
    font = "monospace 14";

    extraConfig = ''
    [urgency=low]
    border-color=#33ccff

    [urgency=normal]
    border-color=#d08770

    [urgency=high]
    border-color=#bf616a
    default-timeout=0

    [category=mdp]
    default-timeout=2000
    group-by=category
    '';
  };

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
}
