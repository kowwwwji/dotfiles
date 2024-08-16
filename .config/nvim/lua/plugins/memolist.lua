return {
  {
    "glidenote/memolist.vim",
    keys = {
      -- TODO: iconを設定したい
      { "<Leader>m", mode = "n", desc = "Memo" },
      { "<Leader>mn", ":MemoNew<CR>", mode = "n", { silent = true, noremap = true }, desc = "New memo" },
      { "<Leader>ml", ":Telescope memo list<CR>", mode = "n", { silent = true, noremap = true }, desc = "Show List" },
      {
        "<Leader>mg",
        ":Telescope memo live_grep<CR>",
        mode = "n",
        { silent = true, noremap = true },
        desc = "Grep",
      },
      { "<Leader>mt", ":e ~/memo/todo.md<CR>", mode = "n", { silent = true, noremap = true }, desc = "Open todo.md" },
    },
    config = function()
      vim.g.memolist_memo_suffix = "md"
      vim.g.memolist_fzf = 1
      vim.g.memolist_path = "~/memo"
      vim.g.memolist_template_dir_path = "$DOTFILES_ROOT/.template/memo/"
    end,
  },
  {
    "delphinus/telescope-memo.nvim",
    requires = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("memo")
    end,
  },
}
