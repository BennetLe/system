{ config, lib, aystem, pkgs, vars, ... }:

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

    diagnostics = {
      update_in_insert = true;
    };

    plugins = {
      lualine.enable = true;
      telescope.enable = true;
      oil.enable = true;
      luasnip.enable = true;
      guess-indent.enable = true;
      web-devicons.enable = true;
      undotree.enable = true;

      mini = {
        enable = true;
        modules = {
          comment = {
            mappings = {
              comment = "<leader>/";
              comment_line = "<leader>/";
              comment_visual = "<leader>/";
              textobject = "<leader>/";
            };
          };
          pairs = {};
        };
      };

      treesitter = {
        enable = true;
        nixGrammars = true;
        settings = {
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = true;
            disable = ''
              function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
                  end
                  end
            '';
          };
          auto_install = true;
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          ts_ls.enable = true;
          lua_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          pyright.enable = true;
          nixd = {
            enable = true;
          };
        };

        keymaps = {
          lspBuf = {
            grn = "rename";
            "<leader>f" = "format";
            gra = "code_action";
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
          { name = "nvim_lsp"; }
          { name = "emoji"; }
          {
            name = "buffer"; # text within current buffer
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            keywordLength = 3;
          }
          {
            name = "path"; # file system paths
              keywordLength = 3;
          }
          {
            name = "luasnip"; # snippets
              keywordLength = 3;
          }
          ];
          mapping = {
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
          };
        };
      };
    };

    colorschemes.gruvbox.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      hidden = true;
      foldlevel = 99;
      shiftwidth = 4;
      tabstop = 4;
      softtabstop = 2;
      expandtab = true;
      autoindent = true;
      wrap = false;
      scrolloff = 25;
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

    keymaps = [
    {
      action = "<cmd>Telescope live_grep<CR>";
      key = "<leader>g";
    }
    {
      action = "<cmd>UndotreeToggle<CR>";
      key = "<leader>u";
    }
    ];
    autoCmd = [
    ];
  };
}
