return {
  {
    "tyru/open-browser.vim",
    event = "VimEnter",
    keys = {
      {
        "gx",
        function()
          return "<Plug>(openbrowser-smart-search)"
        end,
        expr = true,
        mode = { "n", "v" },
      },
    },
  },
  {
    "tyru/open-browser-github.vim",
    dependencies = "tyru/open-browser.vim",
    event = "VimEnter",
    keys = {
      {
        "<leader>gx",
        ":OpenGithubFile<CR>",
        silent = true,
      },
    },
  },
  {
    "previm/previm",
    dependencies = "tyru/open-browser.vim",
    ft = { "md", "markdown" },
    lazy = true,
    keys = {
      {
        "<Leader>p",
        ":PrevimOpen<CR>",
        silent = true,
      },
    },
  },
  {
    "plasticboy/vim-markdown",
    ft = { "md", "markdown" },
    lazy = true,
  },
}
