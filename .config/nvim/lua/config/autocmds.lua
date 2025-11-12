-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Filetype settings
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.dockerignore",
  callback = function()
    vim.bo.filetype = "gitignore"
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { ".env", ".env.*" },
  callback = function()
    vim.bo.filetype = "dotenv"
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.sh",
  callback = function()
    vim.bo.filetype = "zsh"
  end,
})

-- helpを右側に開く
vim.cmd("autocmd FileType help wincmd L")
