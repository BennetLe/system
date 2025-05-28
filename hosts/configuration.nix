{
  lib,
  config,
  pkgs,
  inputs,
  vars,
  ...
}: let
  terminal = pkgs.${vars.terminal};
in {
  imports =
    (import ../modules/editors)
    ++ (import ../modules/themes);

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
      "dialout"
      "input"
      "libvirtd"
      "kvm"
      "video"
      "audio"
      "lp"
      "scanner"
      "docker"
      "disk"
      "adbusers"
    ];
    shell = pkgs.nushell;
    useDefaultShell = true;
  };

  users.defaultUserShell = pkgs.nushell;

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

  security = {
    rtkit.enable = true;
    pam = {
      services = {
        # kwallet.enableKwallet = true;
        # login.enableKwallet = true;
        sddm = {
          # enableKwallet = true;
        };
        # login.kwallet = {
        # enable = true;
        # };
        kde = {
          allowNullPassword = true;
          # kwallet = {
          #   enable = true;
          # };
        };
      };
    };
  };

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
      nushell
      kitty
      hyprland
      waybar
      (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))
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
      fastfetch
      dbus
      wmctrl
      jre8
      jdk17
      obsidian
      cascadia-code
      wineWowPackages.stable
      winetricks
      wineWowPackages.waylandFull
      wineWow64Packages.stable
      wineWow64Packages.waylandFull
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
      qFlipper
      hyprshot
      iproute2
      spice-vdagent
      spice
      desmume
      jetbrains.idea-ultimate
      jdt-language-server
      waydroid
      burpsuite
      anki
      nextcloud-client
      mangohud
      quickemu
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
      thunderbird
      uv
      zimfw
      fd
      nixfmt-rfc-style
      htop
      nix-alien
      icu76
      nix-ld
      inputs.hyprland-qtutils.packages."${pkgs.system}".default
      kdePackages.kcalc
      # kdePackages.kwallet-pam
      xwayland
      (callPackage ./../pkgs/sddm-astronaut-theme.nix {
        theme = "astronaut";
      })
      rpi-imager
      hyprpolkitagent
      libreoffice
      hyphenDicts.de_DE
      gimp-with-plugins
      darktable
      numlockx
      lsof
      appimage-run
      texliveFull
      brave
      gnupg
      encfs
      unzip
      gnumake
      solaar
      nixd
      patchelf
      gcc
      protonmail-bridge-gui
      seahorse
      libsForQt5.qtstyleplugin-kvantum
      kdePackages.qtstyleplugin-kvantum
      nssmdns
      eza
      yazi-unwrapped
      imagemagick
      ueberzugpp
      ffmpeg-full
      ranger
      rustc
      cargo
      gparted
      lazydocker
      xh
      bacon
      cargo-info
      fselect
      rusty-man
      delta
      wiki-tui
      just
      mask
      mprocs
      presenterm

      # Pentesting
      nmap
      wordlists
      gobuster
    ];
  };

  programs = {
    hyprland.enable = true;
    virt-manager.enable = true;
    zsh.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamescope = {
      enable = true;
      package = pkgs.gamescope.overrideAttrs (_: {
        NIX_CFLAGS_COMPILE = ["-fno-fast-math"];
      });
    };
    gamemode.enable = true;
    # neovim.defaultEditor = true;
    nix-ld.enable = true;
    uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor manager by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
      };
    };
    direnv.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Name = "Hello";
          ControllerMode = "dual";
          FastConnectable = "true";
          Experimental = "true";
        };
        Policy = {
          AutoEnable = "true";
        };
      };
    };
    enableAllFirmware = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    xserver.videoDrivers = ["amdgpu"];
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        splix
        # canon-cups-ufr2
        ijs
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    libinput.enable = true;

    displayManager = {
      defaultSession = "hyprland";
      sddm = {
        enable = true; # Enable SDDM.
        extraPackages = with pkgs; [
          kdePackages.qtsvg
          kdePackages.qtmultimedia
          kdePackages.qtvirtualkeyboard
        ];
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        settings = {
          Display = {
            PrimaryMonitor = "DP-1";
          };
        };
      };
    };

    desktopManager.plasma6.enable = true;
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      displayManager = {
        setupCommands = ''
          xrandr --output DP-1 --primary --auto
        '';
        # gdm = {
        #   enable = true;
        #   wayland = true;
        # };
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

    udev = {
      enable = true;
      packages = with pkgs; [
        via
        android-udev-rules
        qmk-udev-rules
        nitrokey-udev-rules
        logitech-udev-rules
        game-devices-udev-rules
      ];
      extraRules = ''
        # CMSIS-DAP for microbit
        ACTION!="add|change", GOTO="microbit_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", TAG+="uaccess"
        LABEL="microbit_rules_end"

        # ESP32-S2-DevKitC-1
        ACTION!="add|change", GOTO="esp32-s2-devkitc-1_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="10c4", ATTR{idProduct}=="ea60", TAG+="uaccess"
        LABEL="esp32-s2-devkitc-1_end"

        # OnePlus
        ACTION!="add|change", GOTO="oneplus_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", ATTR{idProduct}=="2769", MODE="0666", TAG+="uaccess"
        LABEL="oneplus_rules_end"

        # Nuphy Gem80
        ACTION!="add|change", GOTO="nuphy_rules_end"
        SUBSYSTEM=="usb", ATTR{idVendor}=="19f5", ATTR{idProduct}=="3275", TAG+="uaccess"
        LABEL="nuphy_rules_end"

        # Flipper Zero
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

        # Vial Universal rule
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

        # Via rule
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

        # Cidooo V21 Pro rule
        ACTION!="add|change", GOTO="cidooo_rules_end"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="320f", ATTRS{idProduct}=="5055", MODE="0666", TAG+="uaccess"
        LABEL="cidooo_rules_end"

        # Solaar
        KERNEL=="uinput", GROUP="input", MODE="0660"
      '';
    };
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
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "dotnet-runtime-7.0.20"
      ];
    };

    overlays = [
      inputs.nix-alien.overlays.default
      inputs.hyprpanel.overlay
    ];
  };

  system = {
    stateVersion = "24.05";
    # fixed printer
    # nssDatabases.hosts = ["resolve [!UNAVAIL=return]"];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      # xdg-desktop-portal-gtk
    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_full;
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
    waydroid.enable = true;
    docker = {
      enable = true;
    };
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
}
