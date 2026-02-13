return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  config = function()
    require("octo").setup()
  end,
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
