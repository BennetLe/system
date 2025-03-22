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
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      fwupd
      brightnessctl
      fprintd
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
