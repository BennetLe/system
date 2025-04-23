{pkgs, ...}: {
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        diagnostics = {
          enable = true;
        };

        options = {
          tabstop = 4;
          shiftwidth = 4;
        };

        keymaps = [
          {
            key = "<leader>d";
            mode = ["n" "v"];
            silent = true;
            action = "\"_d";
          }
          # disable arrow keys
          {
            key = "<Left>";
            mode = ["n" "v"];
            action = "";
          }
          {
            key = "<Right>";
            mode = ["n" "v"];
            action = "";
          }
          {
            key = "<Up>";
            mode = ["n" "v"];
            action = "";
          }
          {
            key = "<Down>";
            mode = ["n" "v"];
            action = "";
          }
        ];

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
          java = {
            enable = true;
          };
          csharp = {
            enable = true;
            lsp.server = "omnisharp";
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
