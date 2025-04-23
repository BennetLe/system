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

      # Pentesting
      nmap
      wordlists
      gobuster
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

  # suspend-then-hibernate
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
