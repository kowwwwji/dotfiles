local function fileExists(filename)
  local file = io.open(vim.fn.expand(filename), "rb")
  if file then
    file:close()
    return true
  else
    return false
  end
end

local skkJisyo = "~/.config/nvim/SKK-JISYO.L"
local function initialize()
  if not (fileExists(skkJisyo)) then
    vim.notify = require("notify")
    vim.fn.system("curl -o - https://skk-dev.github.io/dict/SKK-JISYO.L.gz" .. "| gunzip >" .. skkJisyo)
    vim.notify("SKKの辞書ファイルをDLしました。", vim.log.levels.INFO, { title = vim.fn.expand("%:t") })
  end
end

return {
  {
    "vim-denops/denops.vim",
  },
  {
    "vim-skk/skkeleton",
    lazy = false,
    dependencies = "vim-denops/denops.vim",
    keys = {
      {
        mode = { "i", "c" },
        "<C-j>",
        "<Plug>(skkeleton-enable)",
        desc = "skkeleton-enable",
      },
    },
    config = function()
      vim.fn["skkeleton#config"]({
        globalDictionaries = { skkJisyo },
        eggLikeNewline = true,
        registerConvertResult = true,
      })
      vim.fn["skkeleton#initialize"]()
    end,
    init = initialize(),
  },
}
