return {
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
            return util.find_git_ancestor(fname) or vim.loop.cwd()
          end,
          settings = {
            sqlLanguageServer = {
              -- 通常は .sqllsrc.json に書くので空でもOK
              connections = {
                {
                  name = "local",
                  adapter = "postgres",
                  host = "127.0.0.1",
                  port = 5432,
                  user = "postgres",
                  password = "passworld",
                  database = "core",
                },
              },
            },
          },
        },
      },
    },
  },
}
