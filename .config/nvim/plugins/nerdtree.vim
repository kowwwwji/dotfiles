let NERDTreeShowHidden = 1
nnoremap <silent><C-e> :call NERDTreeFindToggle()<CR>

function! NERDTreeFindToggle() abort
  if (exists("b:NERDTree") && b:NERDTree.isTabTree()) 
    NERDTreeClose
  else
    NERDTreeFind
  endif
endfunction

"引数なしでvimを開いたらNERDTreeを起動、
"引数ありならNERDTreeは起動せず、引数で渡されたファイルを開く。
autocmd vimenter * if !argc() | NERDTreeVCS | endif

"他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"<CR>だとファイルを開いてからNeardTreeを閉じる
let NERDTreeCustomOpenArgs= {'file':{'keepopen':0}}

autocmd FileType nerdtree nmap <buffer> o go
