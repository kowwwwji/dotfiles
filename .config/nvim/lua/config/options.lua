-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
-- 行頭行末の左右移動で行をまたぐ
vim.opt.whichwrap = "b,s,h,l,[,],<,>,~"

-- helpを右側に出す
vim.opt.splitright = true

-- 不可視文字
vim.opt.list = true
vim.opt.listchars = {
  tab = "»»",
  trail = "-",
  eol = "↲",
  extends = "❯",
  precedes = "❮",
  nbsp = "%",
}

-- スワップファイルを作らない
vim.opt.swapfile = false

-- 日本語（CJK文字）を spell check の対象外にする
-- LazyVim が markdown 等で spell を有効化するが、spelllang=en のままだと
-- 日本語がすべて誤字扱いされて下線がつくため（:h spell-cjk）
vim.opt.spelllang = { "en", "cjk" }
