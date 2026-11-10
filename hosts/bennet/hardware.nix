# Hand-maintained hardware settings for this host.
# hardware-configuration.nix is generated (nixos-generate-config --show-hardware-config) and must not be edited.
{...}: {
  boot.kernelModules = [
    "btusb"
    "usbip_core"
    "usbip_host"
  ];

  # Boot even when the data HDD is missing or broken
  fileSystems."/media/IronWolf".options = ["nofail"];

  hardware = {
    steam-hardware.enable = true;
    logitech.wireless.enable = true;
  };
}
