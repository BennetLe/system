{
  config,
  lib,
  pkgs,
  nvf,
  ...
}:

{
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };
        
        languages = {
          nix.enable = true;
        };
      };
    };
  };
}
