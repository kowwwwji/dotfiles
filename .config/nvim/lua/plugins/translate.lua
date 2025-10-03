return {
  "skanehira/translate.vim",
  keys = {
    { "<Leader>h", nil, mode = { "n", "v" }, desc = "Translate" },
    { "<Leader>he", ":Translate<CR>", mode = { "n", "v" }, desc = "English => Japanese" },
    { "<Leader>hj", ":Translate!<CR>", mode = { "n", "v" }, desc = "Japanese => English" },
  },
  opts = {
    translate_source = "en",
    translate_target = "ja",
    -- if you want use popup window, set value 1
    translate_popup_window = 1,
    -- set buffer window height size if you doesn't use popup window
    -- translate_winsize = 5,
  },
}
