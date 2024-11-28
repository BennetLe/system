{ inputs, pkgs, ... }:

{
  home = {
    packages = [
    ];

    file = {
    };

    sessionVariables = {
    };
  };

  nixpkgs.config.allowUnfree = true;
}
