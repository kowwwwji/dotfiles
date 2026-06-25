-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.g.python3_host_prog = "~/.poetry/nv/.venv/bin/python"
vim.g.neovim_ruby_host = "~/.asdf/shims/ruby"

-- machine固有設定（存在すれば読み込む。git管理外: lua/config/local.lua）
pcall(require, "config.local")
