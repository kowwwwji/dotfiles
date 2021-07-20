let g:previm_open_cmd = 'open -a Google\ Chrome'
let g:previm_custom_css_path = '~/.ghq/github.com/kowwwwji/dotfiles/.template/github-markdown.css'

augroup PrevimSettings
  autocmd!
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
  nnoremap <leader>o :PrevimOpen<CR>
augroup END
