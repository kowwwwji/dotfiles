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
        gopls = {
          -- gopls v0.22 は semantic token modifier を index 17 まで送るが、semanticTokens を
          -- initializationOptions で渡さないと initialize 応答で semanticTokensProvider を
          -- advertise しない。その状態だと LazyVim go.lua の workaround が「標準 10 modifier」で
          -- provider を手生やしし、gopls の 17 index を 10 個の legend でデコードするため
          -- Neovim 0.12 が semantic_tokens.lua:66 "table index is nil" で落ちていた。
          -- init_options で渡すと gopls がネイティブの 17 modifier legend を advertise し、
          -- workaround 不要で正しくデコードされる（go.lua の workaround は guard で no-op になる）。
          init_options = { semanticTokens = true },
        },
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
