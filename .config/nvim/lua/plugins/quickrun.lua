-- vim-quickrun: 編集中のファイル（または選択範囲）をその場で実行する
-- 成功時は下部 split に出力、失敗時は quickfix に流し、結果を通知で知らせる
return {
  "thinca/vim-quickrun",
  dependencies = {
    -- Neovim の jobstart で非同期実行する runner（本体同梱の runner は同期でブロックする）
    "lambdalisue/vim-quickrun-neovim-job",
  },
  cmd = "QuickRun",
  keys = {
    { "<Leader>r", ":QuickRun<CR>", mode = { "n", "v" }, silent = true, desc = "QuickRun" },
  },
  init = function()
    vim.g.quickrun_config = {
      _ = {
        runner = "neovim_job",
        -- outputter/error: 成功と失敗で出力先を切り替える
        outputter = "error",
        ["outputter/error/success"] = "buffer",
        ["outputter/error/error"] = "quickfix",
        ["outputter/buffer/opener"] = ":botright 15split",
        ["outputter/buffer/close_on_empty"] = 1,
      },
    }
  end,
  config = function()
    -- 成功/失敗の通知 hook。quickrun の hook は funcref を持つ Vim の辞書が必要なため
    -- vimscript で定義し、luaeval 経由で vim.notify（nvim-notify）へ渡す
    vim.cmd([[
      let s:notify_hook = {}

      function! s:notify_hook.on_success(session, context) abort
        call luaeval('vim.notify(_A, vim.log.levels.INFO, { title = "QuickRun" })',
        \ 'Success: ' . a:session.config.command)
      endfunction

      function! s:notify_hook.on_failure(session, context) abort
        call luaeval('vim.notify(_A, vim.log.levels.ERROR, { title = "QuickRun" })',
        \ 'Error: ' . a:session.config.command)
      endfunction

      let g:quickrun_config['_']['hooks'] = [s:notify_hook]
    ]])
  end,
}
