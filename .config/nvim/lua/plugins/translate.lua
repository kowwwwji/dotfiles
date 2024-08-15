return {
  "skanehira/translate.vim",
  keys = {
    {
      mode = { "n", "v" },
      "<Leader>t",
      -- TODO: iconを設定したい
      desc = "Translate",
    },
    {
      mode = { "n", "v" },
      "<Leader>te",
      ":Translate<CR>",
      desc = "English => Japanese",
    },
    {
      mode = { "n", "v" },
      "<Leader>tj",
      ":Translate!<CR>",
      desc = "Japanese => English",
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
