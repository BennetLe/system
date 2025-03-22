{pkgs, ...}: {
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        spellcheck = {
          languages = [
            "en"
            "de"
          ];
        };

        searchCase = "smart";
        useSystemClipboard = true;

        visuals = {
          nvim-web-devicons.enable = true;
        };

        ui = {
          borders.plugins.lsp-signature.enable = true;
        };

        tabline.nvimBufferline.setupOpts.options.diagnostics_update_in_insert = true;

        lazy = {
          plugins = {
            "guess-indent.nvim" = {
              package = pkgs.vimPlugins.guess-indent-nvim;
              setupModule = "guess-indent";
            };

            "oil.nvim" = {
              package = pkgs.vimPlugins.oil-nvim;
              setupModule = "oil";
            };

            "undotree" = {
              package = pkgs.vimPlugins.undotree;

              # load on keymap
              keys = [
                {
                  key = "<leader>u";
                  action = ":UndotreeToggle<CR>";
                  mode = "n";
                }
              ];
            };
            "nvzone-typr" = {
              package = pkgs.vimPlugins.nvzone-typr;
            };
          };
        };

        mini = {
          animate.enable = true;
          basics.enable = true;
          comment = {
            enable = true;
            setupOpts = {
              mappings = {
                comment = "<leader>/";
                comment_line = "<leader>/";
                comment_visual = "<leader>/";
                textobject = "<leader>/";
              };
            };
          };
          git.enable = true;
          hipatterns.enable = true;
          icons.enable = true;
          indentscope.enable = true;
          move.enable = true;
          pairs.enable = true;
        };

        snippets = {
          luasnip.enable = true;
        };

        statusline = {
          lualine.enable = true;
        };
        telescope = {
          enable = true;
          mappings = {
            findFiles = "<leader>fd";
            liveGrep = "<leader>ff";
            helpTags = "<leader>fh";
          };
        };

        autocomplete = {
          blink-cmp = {
            enable = true;
            mappings = {
              close = "<C-e>";
              complete = "<C-Space>";
              confirm = "<C-y>";
              next = "<C-n>";
              previous = "<C-p>";
            };
          };
        };

        lsp = {
          formatOnSave = true;
          mappings = {
          };
        };

        languages = {
          enableLSP = true;
          enableTreesitter = true;
          enableFormat = true;
          nix = {
            enable = true;
            extraDiagnostics = {
              enable = true;
            };
            lsp = {
              enable = true;
              server = "nixd";
            };
          };
          ts = {
            enable = true;
          };
          rust = {
            enable = true;
            crates.enable = true;
            dap.enable = true;
          };
          zig = {
            enable = true;
            dap.enable = true;
          };
        };

        binds = {
          whichKey = {
            enable = true;
          };
        };
      };
    };
  };
}
