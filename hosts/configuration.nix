{
  lib,
  config,
  pkgs,
  inputs,
  vars,
  ...
}:

let
  terminal = pkgs.${vars.terminal};
in
{
  imports = (import ../modules/editors);

  boot = {
  };

  users.users.${vars.user} = {
    isNormalUser = true;
    description = "Bennet";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "plugdev"
      "input"
      "libvirtd"
      "video"
      "audio"
      "lp"
      "scanner"
    ];
    shell = pkgs.zsh;
  };

  users.defaultUserShell = pkgs.zsh;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "us";

  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    carlito # NixOS
    vegur # NixOS
    source-code-pro
    jetbrains-mono
    font-awesome # Icons
    corefonts # MS
    noto-fonts # Google + Unicode
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    cascadia-code
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  environment = {
    variables = {
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    sessionVariables = {
      NXIOS_OZONE_WL = "1";
      STEAM_EXTRA_COMPAT_TOOLS_PATH = "/home/bennet/.steam/root/compatibilitytools.d";
    };
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      keepassxc
      git
      gh
      neovim
      zsh
      kitty
      hyprland
      waybar
      (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      }))
      mako
      libnotify
      swww
      rofi-wayland
      networkmanagerapplet
      pavucontrol
      playerctl
      imagemagick
      nomacs
      alsa-utils
      spotify
      neofetch
      dbus
      protonup
      atlauncher
      prismlauncher
      wmctrl
      jre8
      google-chrome
      obsidian
      cascadia-code
      heroic
      wineWowPackages.stable
      winetricks
      wineWowPackages.waylandFull
      wofi
      hyprlock
      hypridle
      hyprpaper
      grim
      slurp
      lazygit
      rust-analyzer
      tree
      xsettingsd
      minicom
      usbutils
      discord
      vesktop
      android-studio
      android-tools
      openvpn
      networkmanager-openvpn
      openresolv
      networkmanager
      thefuck
      via
      gtypist
      kdotool
      dotool
      jq
      bat
      strawberry
      p7zip
      lutris-unwrapped
      r2modman
      qFlipper
      hyprshot
      qemu
      libvirt
      qemu_kvm
      iproute2
      kvmtool
      virt-manager
      virtio-win
      spice-vdagent
      spice
      desmume
      jetbrains.idea-ultimate
      jdt-language-server
      melonDS
      waydroid
      burpsuite
      chromium
      bottles
      protonup-qt
      anki
      nextcloud-client
      mangohud
      quickemu
      protonvpn-gui
      gvfs
      nemo-with-extensions
      jmtpfs
      go-mtpfs
      android-file-transfer
      obs-studio
      vlc
      qbittorrent
      scrcpy
      wireplumber
      gnome-keyring
      seahorse
      tmux
      stirling-pdf
      mousai
      textpieces
      easyeffects
      headsetcontrol
      ferdium
      switcheroo
      onlyoffice-desktopeditors
      localsend
      python313
      lzip
      moonlight-qt
      eww
      wl-clipboard
      coreutils
      killall
      ranger
      zinit
      oh-my-posh
      fzf
      zoxide
      direnv
      thunderbird
      uv
      zimfw
      fd
      nixfmt-rfc-style
      htop
      nix-alien
      icu
      icu76
      nix-ld
      inputs.hyprland-qtutils.packages."${pkgs.system}".default
    ];
  };

  programs = {
    hyprland.enable = true;
    virt-manager.enable = true;
    zsh.enable = true;
    firefox.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    neovim.defaultEditor = true;
    nix-ld.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
    printing = {
      enable = true;
    };
    libinput.enable = true;

    displayManager = {
      defaultSession = "hyprland";
    };

    desktopManager.plasma6.enable = true;
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
    };
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    flatpak.enable = true;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      inputs.nix-alien.overlays.default
    ];
  };

  system = {
    stateVersion = "24.05";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
    waydroid.enable = true;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # home-manager.users.${vars.user} = {
  # home = {
  # stateVersion = "24.05";
  # };
  # programs = {
  # home-manager.enable = true;
  # };
  # };

  services.udev.extraRules = ''
    # CMSIS-DAP for microbit
        ACTION!="add|change", GOTO="microbit_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", TAG+="uaccess"
        LABEL="microbit_rules_end"
        ACTION!="add|change", GOTO="oneplus_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", ATTR{idProduct}=="2769", MODE="0666", TAG+="uaccess"
        LABEL="oneplus_rules_end"
        ACTION!="add|change", GOTO="nuphy_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3275", TAG+="uaccess"
        LABEL="nuphy_rules_end"
        ACTION!="add|change", GOTO="flipper_rules_end"
    #Flipper Zero serial port
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", TAG+="uaccess", GROUP="dialout"
    #Flipper Zero DFU
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", ATTRS{manufacturer}=="STMicroelectronics", TAG+="uaccess", GROUP="dialout"
    #Flipper ESP32s2 BlackMagic
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="40??", ATTRS{manufacturer}=="Flipper Devices Inc.", TAG+="uaccess", GROUP="dialout"
    #Flipper U2F
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5741", ATTRS{manufacturer}=="Flipper Devices Inc.", ENV{ID_SECURITY_TOKEN}="1"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
        LABEL="flipper_rules_end"
  '';
}
