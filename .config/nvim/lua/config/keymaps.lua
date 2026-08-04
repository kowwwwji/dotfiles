-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", ";", ":")
vim.keymap.set("n", ":", ";")

-- Buffer Delete Shortcut
vim.keymap.set("n", "q", function()
  Snacks.bufdelete()
end, { silent = true })

-- move line
-- Option + J/K
-- ∆ == J ˚ == K
vim.keymap.set("n", "˚", ":m .-2<CR>==", { silent = true })
vim.keymap.set("n", "∆", ":m .+1<CR>==", { silent = true })
vim.keymap.set("i", "˚<Esc>", ":m .-2<CR>==gi", { silent = true })
vim.keymap.set("i", "∆<Esc>", ":m .+1<CR>==gi", { silent = true })
vim.keymap.set("v", "˚", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "∆", ":m '>+1<CR>gv=gv", { silent = true })

-- 行移動を <A-j>/<A-k> から <C-A-j>/<C-A-k> へ移設
-- aerospace が OS レベルで alt-hjkl を奪う（フォーカス移動）ため、LazyVim デフォルトの
-- <A-j>/<A-k> はアプリに届かず永遠に発火しない。ctrl を足した位置に同じ動作を再定義する。
-- <C-j>/<C-k>（ウィンドウ移動）とも aerospace のバインドとも衝突しない。
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")
vim.keymap.set("n", "<C-A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<C-A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<C-A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<C-A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<C-A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<C-A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- 選択時に改行を含まない
vim.keymap.set("v", "$", "g_", { silent = true })

-- 折りたたみ
-- WezTerm の Kitty Keyboard Protocol + tmux の extended-keys 経由で <S-CR> が届く
-- 通常バッファでのみ fold 操作にし、quickfix/help などの特殊バッファでは
-- 本来の <CR>/<S-CR> （quickfix のジャンプ等）を維持する
vim.keymap.set("n", "<CR>", function()
  return vim.bo.buftype == "" and "zo<CR>" or "<CR>"
end, { expr = true, silent = true })
vim.keymap.set("n", "<S-CR>", function()
  return vim.bo.buftype == "" and "zc<CR>" or "<S-CR>"
end, { expr = true, silent = true })

-- Command mode でのカーソル移動
vim.keymap.set("c", "<C-h>", "<Left>")
vim.keymap.set("c", "<C-l>", "<Right>")
vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-e>", "<End>")
vim.keymap.set("c", "<Up>", "<C-p>")
vim.keymap.set("c", "<Down>", "<C-n>")

-- GitHub PR をブラウザで開く
vim.keymap.set("n", "<leader>gw", function()
  vim.fn.system("gh pr view --web")
  if vim.v.shell_error ~= 0 then
    vim.notify("No PR found for current branch", vim.log.levels.WARN)
  end
end, { desc = "Open PR in browser" })
