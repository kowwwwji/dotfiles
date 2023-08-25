return {
  {
    "tyru/open-browser.vim",
    event = "VimEnter",
    keys = {
      {
        "<Leader>o",
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
        "<leader>gp",
        ":OpenGithubFile<CR>",
        silent = true,
      },
    },
  },
  {
    "previm/previm",
    ft = { "md", "markdown" },
    lazy = true,
    keys = {
      {
        "<Leader>p",
        ":PrevimOpen<CR>",
        mode = "n",
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
