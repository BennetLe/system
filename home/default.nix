{inputs, nixpkgs, home-manager, vars, ... }:

let
  system = "x86_64-linux";
in
{
  bennet = home-manager.lib.homeManagerConfiguration {
    inherit nixpkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ./bennet.nix
      {
        home = {
          username = "bennet";
	  homeDirectory = "/home/bennet";
	  packages = [ nixpkgs.home-manager ];
	  stateVersion = "24.05";
	};
      }
    ];
  };
}
