return {
  {
    "roodolv/markdown-toggle.nvim",
    branch = "main",
    opt = {
      enable_box_cycle = true,
      -- box_table = { "x" },
    },
    ft = { "markdown", "markdown.mdx", "md" },
    keys = {
      {
        "≈", -- option + x
        "<cmd>lua require('markdown-toggle').checkbox()<CR>",
        mode = { "n", "v" },
        { silent = true, noremap = true },
      },
    },
  },
}
