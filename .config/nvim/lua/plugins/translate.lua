return {
  "skanehira/translate.vim",
  opt = {
    translate_source = "en",
    translate_target = "ja",
    -- if you want use popup window, set value 1
    translate_popup_window = 0,
    -- set buffer window height size if you doesn't use popup window
    translate_winsize = 5,
    vim.keymap.set({ "n", "v" }, "<Leader>h", ":Translate<CR>", { silent = true, desc = "Translate English" }),
    vim.keymap.set({ "n", "v" }, "<Leader>H", ":Translate!<CR>", { silent = true, desc = "Translate Japanese" }),
    vim.keymap.set({ "n" }, "<Esc><Esc><Esc>", ":bw translate://result<CR>", { silent = true }),
  },
}
