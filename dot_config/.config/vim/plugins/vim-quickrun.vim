nnoremap <silent> <F5> :call quickrun#run()<CR>
vnoremap <silent> <F5> :QuickRun -mode v<CR>
let g:quickrun_config = {
  \ '_': {'split': ''},
\}
""let g:quickrun_config.javascript = {
""  \ 'command': 'gjs',
""  \ 'exec': '$c %s',
""\ }
set splitright
