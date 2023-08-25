-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Filetype settings
vim.cmd("autocmd BufNewFile,BufRead *.dockerignore setfiletype gitignore")
vim.cmd("autocmd BufNewFile,BufRead *.env.* setfiletype bash")

-- helpを右側に開く
vim.cmd("autocmd FileType help wincmd L")
