{
  inputs,
  nixpkgs,
  home-manager,
  vars,
  nixvim,
  nvf,
  ...
}: let
  system = "x86_64-linux";
  lib = nixpkgs.lib;
in {
  bennet = lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs system vars;
      host = {
        hostName = "bennet";
      };
    };
    modules = [
      nixvim.nixosModules.nixvim
      nvf.nixosModules.default
      ./bennet
      ./configuration.nix

      inputs.stylix.nixosModules.stylix
      inputs.spicetify-nix.nixosModules.spicetify

      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "old";
        };
      }
    ];
  };
  framework = lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs system vars;
      host = {
        hostName = "bennet";
      };
    };
    modules = [
      nixvim.nixosModules.nixvim
      nvf.nixosModules.default
      ./framework
      ./configuration.nix

      inputs.stylix.nixosModules.stylix
      inputs.spicetify-nix.nixosModules.spicetify

      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "old";
        };
      }
    ];
  };
}
