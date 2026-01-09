return {
  {
    "saghen/blink.cmp",
    opts = {
      --snippets
      snippets = {
        preset = "default",
      },

      -- 見た目
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      -- 補完挙動
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },

        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },

        ghost_text = {
          enabled = vim.g.ai_cmp,
        },

        -- ★ 自動選択を無効化
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },

      -- 補完ソース
      sources = {
        compat = {},
        default = { "lsp", "path", "snippets", "buffer" },
      },

      -- コマンドライン補完
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = false,
          ["<Left>"] = false,
        },
        completion = {
          list = {
            selection = {
              preselect = false,
            },
          },
          menu = {
            auto_show = function()
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = {
            enabled = true,
          },
        },
      },

      -- ★ Tab 補完派向け keymap
      keymap = {
        preset = "none",

        ["<c-n>"] = {
          "select_next",
          "snippet_forward",
          "fallback",
        },

        ["<c-p>"] = {
          "select_prev",
          "snippet_backward",
          "fallback",
        },

        ["<CR>"] = { "accept", "fallback" },
      },
    },
  },
}
