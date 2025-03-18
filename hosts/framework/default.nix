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
    ];
  };
}
