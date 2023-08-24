return {
  "skanehira/translate.vim",
  keys = {
    {
      mode = { "n", "v" },
      "<Leader>h",
      ":Translate<CR>",
      desc = "Translate English",
    },
    {
      mode = { "n", "v" },
      "<Leader>H",
      ":Translate!<CR>",
      desc = "Translate Japanese",
    },
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
