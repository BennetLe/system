{inputs, nixpkgs, home-manager, vars, ... }:

let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  bennet = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs vars; };

    modules = [
      ./bennet.nix
      {
        home = {
          username = "bennet";
	        homeDirectory = "/home/bennet";
	        packages = [ pkgs.home-manager ];
	        stateVersion = "24.05";
	      };
      }
    ];
  };
}
