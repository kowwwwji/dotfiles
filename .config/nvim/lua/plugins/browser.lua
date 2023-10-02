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
        desc = "Search cursol/selection words in web",
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
        desc = "Preview markdown",
      },
    },
  },
  {
    "almo7aya/openingh.nvim",
    keys = {
      {
        "<Leader>gr",
        ":OpenInGHRepo <CR>",
        mode = "n",
        { silent = true, noremap = true },
        desc = "OpenInGHRepo",
      },
      {
        "<Leader>gf",
        ":OpenInGHFile <CR>",
        mode = "n",
        { silent = true, noremap = true },
        desc = "OpenInGHFile",
      },
      {
        "<Leader>gf",
        ":OpenInGHFileLines <CR>",
        mode = "v",
        { silent = true, noremap = true },
        desc = "OpenInGHFileLines",
      },
    },
  },
}
