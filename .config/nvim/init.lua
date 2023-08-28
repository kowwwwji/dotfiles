-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.fn.has("python3") then
  vim.g.python3_host_prog = "~/.asdf/shims/python3"
end
