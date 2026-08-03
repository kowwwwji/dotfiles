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
  pattern = "*.sh",
  callback = function()
    vim.bo.filetype = "zsh"
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.gs",
  callback = function()
    vim.bo.filetype = "javascript"
  end,
})

-- helpを右側に開く
vim.cmd("autocmd FileType help wincmd L")

-- markdown を terminal-browser でプレビュー（.scripts/md-preview）。
-- <leader>cp は廃止した markdown-preview.nvim のキーの引き継ぎ
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.keymap.set("n", "<leader>cp", function()
      local stderr = {}
      vim.fn.jobstart({ "md-preview", vim.api.nvim_buf_get_name(ev.buf) }, {
        stderr_buffered = true,
        on_stderr = function(_, data)
          stderr = data
        end,
        -- 失敗が無反応に見えないよう通知する（依存不足・未保存バッファ等）
        on_exit = function(_, code)
          if code ~= 0 then
            vim.notify(table.concat(stderr, "\n"), vim.log.levels.ERROR)
          end
        end,
      })
    end, { buffer = ev.buf, desc = "Preview in terminal-browser" })
  end,
})
