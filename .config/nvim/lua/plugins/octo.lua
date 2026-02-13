return {
  "pwntester/octo.nvim",
  keys = {
    {
      "<leader>gp",
      function()
        vim.notify("Opening PR...", vim.log.levels.INFO)
        vim.cmd("Octo pr")
      end,
      desc = "Open current branch PR (Octo)",
    },
    { "<leader>gP", "<cmd>Octo pr list<CR>", desc = "List PRs (Octo)" },
  },
}
