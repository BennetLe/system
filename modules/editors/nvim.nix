{ config, lib, system, pkgs, vars, ... }:

let
  colors = import ../theming/colors.nix;

in
{
  environment = {
    systemPackages = with pkgs; [
      go
      nodejs
      (python3.withPackages (ps: with ps; [
        pip
      ]))
      ripgrep
      # zig
    ];
    variables = {
      PATH="$HOME/.npm-packages/bin:$PATH";
      NODE_PATH="$HOME/.npm-packages/lib/node_modules:$NODE_PATH:";
    };
  };

  programs.nixvim = {
    enable = true;
    enableMan = false;
    viAlias = true;
    vimAlias = true;
    autoCmd = [
      {
        event = "VimEnter";
        command = "set nofoldenable";
        desc = "Unfold All";
      }
    ];

    opts = {
      number = true;
      relativenumber = true;
      hidden = true;
      foldlevel = 99;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      autoindent = true;
      wrap = false;
      scrolloff = 5;
      spell = false;
      spelllang = [ "en" ];
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
