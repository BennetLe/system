{
  description = "A very basic flake";

  inputs = {
     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

     home-manager = {
       url = "github:nix-community/home-manager/master";
       inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list where available
    };

    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixvim, ... }:
    let
      vars = {
        user = "bennet";
	localtion = "$HOME/system";
	terminal = "kitty";
	editor = "nvim";
      };
    in {
      nixosConfigurations = (
        import ./hosts {
	  inherit (nixpkgs) lib;
	  inherit inputs nixpkgs home-manager vars nixvim;
	}
      );

      homeConfigurations = (
        import ./home {
	  inherit (nixpkgs) lib;
	  inherit inputs nixpkgs home-manager vars;
	}
      );
    };
}
