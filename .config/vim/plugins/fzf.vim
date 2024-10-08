command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'source': 'rg --hidden --ignore .git -g ""'}), <bang>0)
command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \   '--hidden',
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%', '?'),
  \   <bang>0)
command! -bang -nargs=* AgAll
  \ call fzf#vim#ag(<q-args>,
  \   '--hidden --unrestricted',
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%', '?'),
  \   <bang>0)

nnoremap <silent> <Leader>ss :Ag<CR>
nnoremap <silent> <Leader>sa :AgAll<CR>
nnoremap <silent> <Leader>f :Files<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>hf :History<CR>
nnoremap <silent> <Leader>hc :History:<CR>
nnoremap <silent> <Leader>hs :History/<CR>
nnoremap <silent> <Leader>m :Map<CR>
