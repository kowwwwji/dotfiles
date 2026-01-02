let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'filename', 'method', 'cocstatus', 'modified'] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead',
  \   'filename': 'LightlineFilename',
  \   'cocstatus': 'coc#status',
  \   'method': 'NearestMethodOrFunction'
  \ },
  \ }

function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

let s:palette = g:lightline#colorscheme#wombat#palette
let s:palette.tabline.tabsel = [ [ '#d0d0d0', '#5f8787', 252, 66, 'bold' ] ]
unlet s:palette

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
