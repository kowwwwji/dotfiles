command! Format :call CocAction('format')

nmap gd <Plug>(coc-definition)
nmap gy <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)
nmap gd <Plug>(coc-definition)
nnoremap <Leader>d :<C-u>CocDiagnostics<CR>

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

""coc completion""""""""""""
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

inoremap <silent><expr> <CR>
      \ coc#pum#visible() ? coc#_select_confirm() : "\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" TODO make prettier eslint configfile
let g:coc_global_extensions = [
      \'coc-actions',
      \'coc-deno',
      \'coc-diagnostic',
      \'coc-dictionary',
      \'coc-docker',
      \'coc-eslint',
      \'coc-git',
      \'coc-highlight',
      \'coc-java',
      \'coc-java-debug',
      \'coc-jedi',
      \'coc-json',
      \'coc-lists',
      \'coc-marketplace',
      \'coc-pairs',
      \'coc-prettier',
      \'coc-snippets',
      \'coc-toml',
      \'coc-tslint-plugin',
      \'coc-tsserver',
      \'coc-ultisnips',
      \'coc-yaml'
\]
