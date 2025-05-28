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

      # Uni
      mongodb-compass
      antlr

      # Games
      prismlauncher
    ];
  };
  services = {
    fprintd = {
      enable = true;
      # tod = {
      #   enable = true;
      #   driver = pkgs.libfprint-2-tod1-vfs0090;
      # };
    };
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
      allowedTCPPorts = [42420 53317];
      allowedUDPPorts = [42420 53317 5353];
    };
  };

  # suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
