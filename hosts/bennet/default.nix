{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs; };
    users = {
      bennet = import ../../home/bennet.nix;
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
      joplin-desktop
      vdhcoapp
      vial
      alpaca
      rocmPackages.rocminfo
      tor-browser
      btop-rocm
      vivaldi
      cloudflared
      nmap
      sqlite-web

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
      spice
      spice-vdagent
      virt-viewer

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
      protontricks
      godot_4
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
    monado = {
      enable = true;
      defaultRuntime = true;
    };
  };
  virtualisation = {
    docker = {
      enable = true;
    };
  };
  nixpkgs.overlays = [
    (final: prev: {
      vintagestory = prev.vintagestory.overrideAttrs (oldAttrs: rec {
        version = "1.20.3";
        src = prev.fetchurl {
          url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
          hash = "sha256-+nEyFlLfTAOmd8HrngZOD1rReaXCXX/ficE/PCLcewg=";
        };
      });
    })
  ];
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 42420 ];
      allowedUDPPorts = [ 42420 ];
    };
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
}
