return {
  {
    "glidenote/memolist.vim",
    keys = {
      { "<Leader>mn", ":MemoNew<CR>", mode = "n", { silent = true, noremap = true }, desc = "Memo New" },
      { "<Leader>ml", ":Telescope memo list<CR>", mode = "n", { silent = true, noremap = true }, desc = "Memo List" },
      {
        "<Leader>mg",
        ":Telescope memo live_grep<CR>",
        mode = "n",
        { silent = true, noremap = true },
        desc = "Memo Grep",
      },
      { "<Leader>mt", ":e ~/memo/todo.md<CR>", mode = "n", { silent = true, noremap = true }, desc = "Open ToDo.md" },
    },
    config = function()
      vim.g.memolist_memo_suffix = "md"
      vim.g.memolist_fzf = 1
      vim.g.memolist_path = "~/memo"
      vim.g.memolist_template_dir_path = "~/.config/memo/template.txt"
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
