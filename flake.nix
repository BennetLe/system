{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list where available
    };

    # Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
    };

    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix.url = "github:ryantm/agenix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nix-alien,
    hyprland-qtutils,
    nvf,
    stylix,
    spicetify-nix,
    nixos-hardware,
    agenix,
    noctalia,
    ...
  }: let
    vars = {
      user = "bennet";
      localtion = "$HOME/system";
      terminal = "kitty";
      editor = "vim";
    };
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = (
      import ./hosts {
        inherit (nixpkgs) lib;
        inherit
          inputs
          nixpkgs
          home-manager
          vars
          nixvim
          nix-alien
          hyprland-qtutils
          nvf
          stylix
          spicetify-nix
          nixos-hardware
          agenix
          noctalia
          ;
      }
    );

    # homeConfigurations."bennet" = home-manager.lib.homeManagerConfiguration {
    #   pkgs = nixpkgs.legacyPackages.${system};
    #   modules = [
    #     ./home/bennet.nix
    #     {
    #       home = {
    #         username = "${vars.user}";
    #         homeDirectory = "/home/${vars.user}";
    #         stateVersion = "24.05";
    #       };
    #     }
    #   ];
    # };
  };
}
