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
    -- ブラウザプレビューは廃止（バッファ内表示へ移行）。
    -- lang.markdown extra（lua/config/lazy.lua で import）が同プラグインを宣言しているため、
    -- 明示的な無効化が必要（自前 spec の削除だけでは extra 側の宣言が生き残る）
    "iamcco/markdown-preview.nvim",
    enabled = false,
  },
  -- テキスト装飾（見出し・テーブル罫線・コードブロック背景）は lang.markdown extra が
  -- 宣言する render-markdown.nvim が担う（<leader>um でトグル）。自前 spec は持たない。
  {
    -- バッファ内の画像・mermaid 描画を有効化（LazyVim コアの snacks.nvim に opts をマージ）
    -- 描画経路: mmdc / imagemagick → kitty graphics protocol → tmux passthrough → Ghostty
    "folke/snacks.nvim",
    opts = {
      image = {
        -- LaTeX 数式の画像化は使わない（LaTeX 環境が必要になるため）
        math = { enabled = false },
      },
    },
  },
}
