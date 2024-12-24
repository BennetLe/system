{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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
      gimp-with-plugins
      darktable
      libreoffice-qt6-unwrapped
      joplin-desktop
      vdhcoapp
    ];
  };

}
