{
  config,
  lib,
  aystem,
  pkgs,
  vars,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      go
      nodejs
      (python3.withPackages (
        ps: with ps; [
          pip
        ]
      ))
      ripgrep
    ];
    variables = {
      PATH = "$HOME/.npm-packages/bin:$PATH";
      NODE_PATH = "$HOME/.npm-packages/lib/node_modules:$NODE_PATH:";
    };
  };

  programs.nixvim = {
    enable = false;
    enableMan = false;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    diagnostics = {
      update_in_insert = true;
    };

    plugins = {
      lualine.enable = true;
      oil.enable = true;
      friendly-snippets.enable = true;
      luasnip.enable = true;
      guess-indent.enable = true;
      web-devicons.enable = true;
      undotree.enable = true;
      lsp-signature.enable = true;
      zig.enable = true;

      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            preset = "default";
            "<Up>" = [
              # "hide"
              "fallback"
            ];
            "<Down>" = [
              # "hide"
              "fallback"
            ];
            highlight = {
              use_nvim_cmp_as_default = true;
            };
            trigger = {
              signature_help = {
                enabled = true;
              };
            };
          };
        };
      };

      telescope = {
        enable = true;
        keymaps = {
          "<leader>fd" = "find_files";
          "<leader>ff" = "live_grep";
          "<leader>fh" = "help_tags";
        };
      };

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
          pairs = { };
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
          pyright.enable = true;
          nixd = {
            enable = true;
          };
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          zls.enable = true;
        };

        keymaps = {
          lspBuf = {
            grn = "rename";
            "<leader>f" = "format";
            gra = "code_action";
            grr = "references";
          };
        };
      };

      cmp = {
        enable = false;
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
            "<C-l>" = ''
                cmp.mapping(function(fallback)
                  vim.snippet.jump(1)
              	end, { "i" })
            '';
            "<C-j>" = ''
                cmp.mapping(function(fallback)
                  vim.snippet.jump(-1)
              	end, { "i" })
            '';

            "<Up>" = ''
                cmp.mapping(function(fallback)
              	cmp.close()
              	fallback()
              	end, { "i" })
            '';
            "<Down>" = ''
                cmp.mapping(function(fallback)
              	cmp.close()
              	fallback()
              	end, { "i" })
            '';

          };
          # experimental = {
          #   ghost_text = true;
          # };
        };
      };
      alpha = {
        enable = true;
        layout = [
          {
            type = "padding";
            val = 2;
          }
          {
            opts = {
              hl = "Type";
              position = "center";
            };
            type = "text";
            val = [
              "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
              "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
              "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
              "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
              "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
              "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "group";
            val = [
              {
                on_press = {
                  __raw = "function() vim.cmd[[ene]] end";
                };
                opts = {
                  shortcut = "n";
                };
                type = "button";
                val = "  New file";
              }
              {
                on_press = {
                  __raw = "function() vim.cmd[[qa]] end";
                };
                opts = {
                  shortcut = "q";
                };
                type = "button";
                val = " Quit Neovim";
              }
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            opts = {
              hl = "Keyword";
              position = "center";
            };
            type = "text";
            val = "Commit to less. Complete more.";
          }
        ];

      };
      harpoon = {
        enable = true;
        enableTelescope = true;
        keymaps = {
          addFile = "<leader>ha";
          toggleQuickMenu = "<leader>hf";
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
      spelllang = [
        "en"
        "de"
      ];
      ignorecase = true;
      smartcase = true;
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
        action = "<cmd>cnext<CR>";
        key = "<M-j>";
      }
      {
        action = "<cmd>cprev<CR>";
        key = "<M-k>";
      }
      {
        action = "<cmd>UndotreeToggle<CR>";
        key = "<leader>u";
      }
      {
        action = "<Nop>";
        key = "gr";
      }
    ];
    autoCmd = [
      {
        event = [
          "LspAttach"
        ];
        desc = "Format current buffer on write";
        callback = {
          __raw = ''
            function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if not client then return end

              vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = args.buf,
                callback = function()
                  vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                end
              })
            end
          '';
        };
      }
    ];
  };
}
