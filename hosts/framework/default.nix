{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      bennet = import ../../home/framework.nix;
    };
  };

  programs = {
    spicetify = {
      enable = true;
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 6;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      # Uni
      mongodb-compass
      antlr

      # Games
      prismlauncher

      fwupd
      brightnessctl
      fprintd
      mysql84
      mysql-workbench
      btop-rocm
      omnisharp-roslyn
      protontricks
      protonup-qt
      godot
      hyprpanel
    ];
  };
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    fprintd = {
      enable = true;
    };
    upower.enable = true;
    fwupd.enable = true;
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
    mongodb = {
      enable = true;
      package = pkgs.mongodb-ce;
    };
  };

  security = {
    pam = {
      services = {
        login = {
          fprintAuth = false;
        };
        sddm = {
          allowNullPassword = true;
          unixAuth = true;
          fprintAuth = false;
        };
      };
    };
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
    firewall = {
      enable = true;
      allowedTCPPorts = [42420 1714 1764 4444 1337 8080];
      allowedUDPPorts = [42420 5353 1714 1764 4444 1337 8080];
    };
  };

  # suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
