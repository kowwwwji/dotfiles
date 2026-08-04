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
          else
            -- プレビューを起動したバッファだけカーソル同期を有効化する
            vim.b[ev.buf].md_preview_sync = true
          end
        end,
      })
    end, { buffer = ev.buf, desc = "Preview in terminal-browser" })

    -- プレビューをカーソル行へ追従スクロールさせる。
    -- CursorMoved 毎では CLI プロセス起動+CDP 往復が重すぎるため、updatetime 経過後に
    -- 1回だけ発火する CursorHold を自然なデバウンスとして使う。
    -- FileType は同一バッファで複数回発火しうるので、augroup(clear) で重複登録を防ぐ。
    local group = vim.api.nvim_create_augroup("md_preview_sync_" .. ev.buf, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = ev.buf,
      callback = function()
        if not vim.b[ev.buf].md_preview_sync then
          return
        end
        vim.fn.jobstart({
          "terminal-browser",
          "action",
          "--",
          "eval",
          ("window.__scrollToLine(%d)"):format(vim.api.nvim_win_get_cursor(0)[1]),
        }, {
          -- browser pane が閉じられた後もカーソル停止のたびプロセスを起動し続けないよう、
          -- 失敗したら沈黙で同期を無効化する（通知はスパムになるので出さない。
          -- 次の <leader>cp 成功で復帰する）
          on_exit = function(_, code)
            if code ~= 0 then
              vim.b[ev.buf].md_preview_sync = false
            end
          end,
        })
      end,
    })
  end,
})
