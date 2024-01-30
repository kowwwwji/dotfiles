return {
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
