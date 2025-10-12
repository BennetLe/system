{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.walker.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      bennet = import ../../home/framework.nix;
    };
  };

  programs = {
    walker = {
      enable = true;
      runAsService = true;
    };
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
      protonup-qt
      protontricks
      protonup
      godot
      hyprpanel
    ];
  };
  services = {
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
    firewall = {
      enable = true;
      allowedTCPPorts = [42420];
      allowedUDPPorts = [42420 5353];
    };
  };

  # suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
