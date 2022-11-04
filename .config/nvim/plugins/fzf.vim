set rtp+=/usr/local/opt/fzf

" for Files
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
" for Ag
autocmd VimEnter * command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
  \                 <bang>0)

nnoremap <silent> <Leader>s :Ag<CR>
nnoremap <silent> <Leader>f :Files<CR>
nnoremap <silent> <Leader>bl :Lines<CR>
nnoremap <silent> <Leader>bf :Buffers<CR>
nnoremap <silent> <Leader>h :History<CR>
nnoremap <silent> <Leader>hc :History:<CR>
nnoremap <silent> <Leader>hs :History/<CR>
nnoremap <silent> <Leader>m :Map<CR>

