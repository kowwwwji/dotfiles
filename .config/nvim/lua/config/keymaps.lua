-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", ";", ":")
vim.keymap.set("n", ":", ";")

-- move line
-- Option + J/K
-- ∆ == J ˚ == K
vim.keymap.set("n", "˚", ":m .-2<CR>==", { silent = true })
vim.keymap.set("n", "∆", ":m .+1<CR>==", { silent = true })
vim.keymap.set("i", "˚<Esc>", ":m .-2<CR>==gi", { silent = true })
vim.keymap.set("i", "∆<Esc>", ":m .+1<CR>==gi", { silent = true })
vim.keymap.set("v", "˚", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "∆", ":m '>+1<CR>gv=gv", { silent = true })

-- 選択時に改行を含まない
vim.keymap.set("v", "$", "g_", { silent = true })

-- 折りたたみ
-- NOTE: iTerm2のKeys>KeyBindings でShift+Enterを設定する必要あり。
vim.cmd("map ✠ <S-CR>")
vim.keymap.set("n", "<CR>", "zo<CR>", { noremap = true })
vim.keymap.set("n", "<S-CR>", "zc<CR>", { noremap = true })

-- TODO: Command mode で選択する。
-- vim.keymap.set("c", "<C-h>", "<Left>")
-- vim.keymap.set("c", "<C-l>", "<Right>")
-- vim.keymap.set("c", "<C-k>", "<Up>")
-- vim.keymap.set("c", "<C-j>", "<Down>")
-- vim.keymap.set("c", "<C-a>", "<Home>")
-- vim.keymap.set("c", "<C-e>", "<End>")
