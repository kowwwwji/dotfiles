let g:netrw_nogx = 1

augroup OpenBrowserSettings
  nmap gx <Plug>(openbrowser-smart-search)
  vmap gx <Plug>(openbrowser-smart-search)
  " 現在開いているファイルをブラウザで開く
  command! OpenBrowserCurrent execute "OpenBrowserSmartSearch" expand("%:p")
augroup END

