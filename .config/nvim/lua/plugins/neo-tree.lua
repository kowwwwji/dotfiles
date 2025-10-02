return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
      end,
      desc = "Explorer NeoTree (root)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root)", remap = true },
    { "<C-e>", "<leader>fe", desc = "Explorer NeoTree (root)", remap = true },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      filtered_items = {
        hide_dotfiles = false,
        hide_by_name = {
          -- '.git',
          -- '.DS_Store',
          -- 'thumbs.db',
        },
      },
    },
    window = {
      mappings = {
        ["<C-v>"] = "open_vsplit",
      },
    },
  },
}
