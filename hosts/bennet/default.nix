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
      vial
      numlockx
      zed-editor
      alpaca
      lsof
      appimage-run
      rocmPackages.rocminfo
      tor-browser
      texliveFull
      protontricks
      btop-rocm

      # VM
      qemu_full
      qemu
      libvirt
      virt-manager
      looking-glass-client
      virtio-win
      kvmtool
      libguestfs-with-appliance
      dmg2img
      tesseract
      nettools

      # Games
      vintagestory
    ];
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = [ "bennet" ];
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    ollama = {
      enable = true;
      acceleration = "rocm";
      environmentVariables = {
        HCC_AMDGPU_TARGET = "gfx1030";
      };
      rocmOverrideGfx = "10.3.0";
    };
  };
  virtualisation = {
    docker = {
      enable = true;
    };
  };
}
