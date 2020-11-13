let NERDTreeShowHidden = 1
nnoremap <silent><C-e> :NERDTreeToggle<CR>

"引数なしでvimを開いたらNERDTreeを起動、
"引数ありならNERDTreeは起動せず、引数で渡されたファイルを開く。
autocmd vimenter * if !argc() | NERDTree | endif

"他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
