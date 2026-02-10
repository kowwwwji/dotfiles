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
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      -- .mdファイルを閉じてもプレビューを閉じない
      vim.g.mkdp_auto_close = 0
    end,
  },
}
