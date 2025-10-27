{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    inputs.walker.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      bennet = import ../../home/bennet.nix;
    };
  };

  stylix = {
    targets = {
      spicetify.enable = false;
    };
  };

  programs = {
    walker = {
      enable = true;
      runAsService = true;
      elephant = {
        config = {
          entries = [
            {
              default = true;
              name = "Brave";
              url = "ttps://search.brave.com/search?q=%TERM%";
            }
          ];
        };
      };
    };
    streamcontroller.enable = true;
    spicetify = let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
      enable = true;
      theme = spicePkgs.themes.text;
      colorScheme = "CatppuccinMocha";
      enabledExtensions = [
        {
          name = "volume-ws.js";
          src = builtins.path {
            path = ./extern/spicetify;
          };
        }
      ];
    };
    kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      timeout = 5;
    };
  };
  environment = {
    systemPackages = with pkgs; [
      inputs.winboat.packages.x86_64-linux.winboat
      # package overlays
      (import ./pkgs/idea-community.nix {inherit pkgs;})
      # Game dev
      godot
      blender-hip
      pixelorama
      blockbench

      # VM
      libvirt
      virt-manager
      looking-glass-client
      virtio-win
      kvmtool
      libguestfs-with-appliance
      dmg2img

      # Games
      vintagestory
      protonup
      atlauncher
      prismlauncher
      heroic
      lutris-unwrapped
      r2modman
      melonDS
      protonup-qt

      joplin-desktop
      vdhcoapp
      vial
      rocmPackages.rocminfo
      rocmPackages.clr.icd
      tor-browser
      btop-rocm
      vivaldi
      cloudflared
      nmap
      sqlite-web
      google-chrome
      tesseract
      nettools
      spice
      virt-viewer
      agenix-cli
      uget
      element-desktop
      hyprpanel
      kid3-qt
      picard
      kdePackages.qt5compat
      libqalculate
      monero-gui
      distrobox
      tigervnc
      rmpc
      freetube
      mpv
      dive
      podman-tui
      podman-compose
      jdk
      jdk25
      handbrake
      freerdp
      gnome-multi-writer
    ];
  };

  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    mpd = {
      enable = true;
      musicDirectory = /home/bennet/Music/music;
      user = "bennet";
      extraConfig = ''
        audio_output {
          type "pulse"
          name "My PulseAudio" # this can be whatever you want
        }
      '';
    };
    spice-vdagentd.enable = true;
    openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = ["bennet"];
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    # ollama = {
    #   enable = true;
    #   acceleration = "rocm";
    #   rocmOverrideGfx = "11.0.1";
    # };
    monado = {
      enable = true;
      defaultRuntime = true;
    };
  };
  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    docker = {
      enable = true;
    };
  };
  nixpkgs = {
    overlays = [
      (_final: prev: {
        vintagestory = prev.vintagestory.overrideAttrs (_oldAttrs: rec {
          version = "1.20.12";
          src = prev.fetchurl {
            url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
            hash = "sha256-h6YXEZoVVV9IuKkgtK9Z3NTvJogVNHmXdAcKxwfvqcE=";
          };
        });
      })
    ];
  };
  networking = {
    nameservers = [
      "100.100.100.100"
      "192.168.178.150"
      "1.1.1.1"
    ];
    search = [
      "tailcd4427.ts.net"
    ];
    interfaces = {
      # enp12s0u2 = {
      #   ipv4.addresses = [
      #     {
      #       address = "192.168.1.1";
      #       prefixLength = 24;
      #     }
      #   ];
      # };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [42420 1714 1764 4444 1337 8080];
      allowedUDPPorts = [42420 5353 1714 1764 4444 1337 8080];
    };
    hosts = {
      # "10.129.251.69" = ["editor.htb"];
    };
  };

  systemd = {
    services = {
      mpd.environment = {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
    };
    user = {
      services.monado.environment = {
        STEAMVR_LH_ENABLE = "1";
        XRT_COMPOSITOR_COMPUTE = "1";
      };
    };
  };

  security.pki.certificateFiles = [
    ./../../modules/certs/mitmproxy-ca-cert-bennet.pem
    ./../../modules/certs/burp.pem
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [pkgs.rocmPackages.clr.icd];
    };
  };
}
