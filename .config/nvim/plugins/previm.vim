let g:previm_open_cmd = 'open -a Google\ Chrome'

augroup PrevimSettings
  autocmd!
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
  nnoremap <silent> <C-m> :PrevimOpen<CR>
  nunmap <CR>
augroup END
