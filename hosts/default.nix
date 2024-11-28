{ inputs, nixpkgs, home-manager, vars, nixvim, ... }:

let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  bennet = lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs system vars;
      host = {
        hostName = "bennet";
        mainMonitor = "DP-2";
        secondMonitor = "DP-1";
      };
    };
    modules = [
      nixvim.nixosModules.nixvim
      ./bennet
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;
      }
    ];
  };
}
