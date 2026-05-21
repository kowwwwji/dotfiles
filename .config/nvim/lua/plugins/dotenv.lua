return {
  {
    "tpope/vim-dotenv",
    cmd = { "Dotenv" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({
        filename = { [".env"] = "conf" },
        pattern = { ["%.env%.[%w_.-]+"] = "conf" },
      })
    end,
  },
}
