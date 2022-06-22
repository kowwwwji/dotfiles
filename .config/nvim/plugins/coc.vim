nmap gd <Plug>(coc-definition)
nmap gy <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)
nmap gd <Plug>(coc-definition)
nnoremap <silent><Leader>a :<C-u>CocDiagnostics<CR>

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)
" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use NVM default nodejs
let g:coc_node_path = expand('$NODE_BIN/node')

command! Format :call CocAction('format')>
