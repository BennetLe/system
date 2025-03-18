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
      timeout = 5;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      fwupd
    ];
  };
}
