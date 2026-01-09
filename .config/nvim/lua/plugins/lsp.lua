return {
  {
    "mason-org/mason.nvim",
  },
  {
    "mason-org/mason-lspconfig.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sqlls = {
          -- Mason で入れたバイナリが自動的にパス解決される
          cmd = { "sql-language-server", "up", "--method", "stdio" },
          filetypes = { "sql" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- fname が文字列であることを保証
            if type(fname) ~= "string" then
              return vim.loop.cwd()
            end
            return util.find_git_ancestor(fname) or vim.loop.cwd()
          end,
        },
      },
    },
  },
}
