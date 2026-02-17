return {
  {
    "dkarter/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    config = function()
      -- 有効にするファイルタイプ
      vim.g.bullets_enabled_file_types = {
        "markdown",
        "text",
        "gitcommit",
      }

      -- リストマーカーの設定
      vim.g.bullets_outline_levels = { "ROM", "ABC", "num", "abc", "rom", "a" }

      -- チェックボックスの切り替えを有効化
      vim.g.bullets_checkbox_markers = " .oOX"

      -- 空のリストアイテムで改行したら自動削除
      vim.g.bullets_delete_last_bullet_if_empty = 1

      -- インデントのネスト
      vim.g.bullets_nested_checkboxes = 1

      -- 改行時にリストを自動継続
      vim.g.bullets_auto_indent_after_colon = 1
    end,
  },
  {
    "roodolv/markdown-toggle.nvim",
    branch = "main",
    opts = {
      enable_box_cycle = true,
      -- box_table = { "x" },
    },
    ft = { "markdown", "markdown.mdx", "md" },
    keys = {
      {
        "≈", -- option + x
        "<cmd>lua require('markdown-toggle').checkbox()<CR>",
        mode = { "n", "v" },
        silent = true,
        noremap = true,
        desc = "Toggle markdown checkbox",
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
