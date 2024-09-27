local actions = require("telescope.actions")
local grep_args = { "--color=never", "--no-heading", "--line-number", "--column", "--smart-case", "--hidden" }

return {
  "nvim-telescope/telescope.nvim",
  keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({})
      end,
      desc = "Find Files (root)",
    },
    {
      "<leader><leader>",
      function()
        require("telescope.builtin").find_files({})
      end,
      desc = "Find Files (root)",
    },
    {
      "<leader>fF",
      function()
        require("telescope.builtin").find_files({
          cwd = vim.fn.expand("%:p:h"),
        })
      end,
      desc = "Find Files (cwd)",
    },
  },
  -- change some options
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
      prompt_position = "top",
      mappings = {
        i = {
          -- InsertModeでもctrl+cで終了できる
          -- ["<esc>"] = actions.close,
        },
      },
    },
    pickers = {
      find_files = {
        hidden = true,
      },
      live_grep = {
        additional_args = function(opts)
          return grep_args
        end,
      },
      grep_string = {
        additional_args = function(opts)
          return grep_args
        end,
      },
    },
  },
}
