" 画面表示の設定{{{
set number         " 行番号を表示する
set cursorline     " カーソル行の背景色を変える
set cursorcolumn   " カーソル列の背景色を変える
set laststatus=2   " ステータス行を常に表示
set cmdheight=1    " メッセージ表示欄
set showmatch      " 対応する括弧を強調表示
set helpheight=999 " ヘルプを画面いっぱいに開く
set list           " 不可視文字を表示
"}}}

" 不可視文字の表示記号指定{{{
set listchars=tab:▸\ ,trail:-,eol:↲,extends:❯,precedes:❮

" カーソルの形
if has('vim_starting')
  " 挿入モード時に非点滅の縦棒タイプのカーソル
  let &t_SI .= "\e[6 q"
  " ノーマルモード時に非点滅のブロックタイプのカーソル
  let &t_EI .= "\e[2 q"
  " 置換モード時に非点滅の下線タイプのカーソル
  let &t_SR .= "\e[4 q"
endif
"}}}

" カーソル移動関連の設定{{{
set backspace=indent,eol,start " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,]  " 行頭行末の左右移動で行をまたぐ
set scrolloff=8                " 上下8行の視界を確保
set sidescrolloff=16           " 左右スクロール時の視界を確保
set sidescroll=1               " 左右スクロールは一文字づつ行う
set virtualedit+=block
"}}}

" プレフィックスキー{{{
let g:EasyMotion_leader_key = '<Space><Space>'
let mapleader = "\<Space>"
nnoremap [GitLeader]    <Nop>
nmap     <Space>g [GitLeader]
"}}}

" ファイル処理関連の設定{{{
set confirm    " 保存されていないファイルがあるときは終了前に保存確認
set hidden     " 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set autoread   " 外部でファイルに変更がされた場合は読みなおす
set nobackup   " ファイル保存時にバックアップファイルを作らない
set noswapfile " ファイル編集中にスワップファイルを作らない
set fileencodings=utf-8,cp932,euc-jp,sjis " ファイルを読み込む時の、文字コード自動判別の順番
set fileformats=unix,dos,mac
"}}}

" 検索/置換の設定{{{
set hlsearch   " 検索文字列をハイライトする
hi Search ctermbg=Red
hi Search ctermfg=White
set incsearch  " インクリメンタルサーチを行う
set ignorecase " 大文字と小文字を区別しない
set smartcase  " 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
set wrapscan   " 最後尾まで検索を終えたら次の検索で先頭に移る
" set gdefault   " 置換の時 g オプションをデフォルトで有効にする
" 常に very magic モードにする
nnoremap / /\v
" ハイライトを消したい時
nnoremap <silent> <Esc><Esc> :noh<CR>
"}}}

" タブ/インデントの設定{{{
set expandtab     " タブ入力を複数の空白入力に置き換える
set tabstop=2     " 画面上でタブ文字が占める幅
set shiftwidth=2  " 自動インデントでずれる幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent    " 改行時に前の行のインデントを継続する
set smartindent   " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
"}}}

" 動作環境との統合関連の設定{{{
" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus
" マウスの入力を受け付ける
set mouse=a
" Windows でもパスの区切り文字を / にする
set shellslash
" インサートモードから抜けると自動的にIMEをオフにする
set iminsert=0
set imsearch=-1
"}}}

" コマンドラインの設定{{{
" コマンドラインモードでTABキーによるファイル名補完を有効にする
set wildmenu wildmode=list:longest,full
" コマンドラインの履歴を10000件保存する
set history=10000
"}}}

" ビープの設定{{{
"ビープ音すべてを無効にする
set visualbell t_vb=
set noerrorbells        "エラーメッセージの表示時にビープを鳴らさない
"}}}

"Remap{{{
"コロンでコマンドモードに入るようにする。
nnoremap ;  :
nnoremap :  ;
vnoremap ;  :
vnoremap :  ;

"JISキーとUSキーの配置のため
inoremap <C-@> <ESC>

"Exコマンドを実装する関数を定義
function! ExecExCommand(cmd)
  silent exec a:cmd
  return ''
endfunction
"インサートモードで移動
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-a> <Home>
inoremap <C-e> <End>
"補完せず補完ウィンドウを閉じてから移動
inoremap <silent><expr><C-b> pumvisible() ? "<C-e><C-r>=ExecExCommand('normal b')<CR>" : "<C-r>=ExecExCommand('normal b')<CR>"
inoremap <silent><expr><C-w> pumvisible() ? "<C-e><C-r>=ExecExCommand('normal w')<CR>" : "<C-r>=ExecExCommand('normal w')<CR>"

"方向キーを使用しなくても検索履歴を使用できるようにする。
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

""タブ
nnoremap <silent> <C-h> :tabprevious<CR>
nnoremap <silent> <C-l> :tabnext<CR>
" nnoremap <silent> <C-l> :+tabmove<CR>
" nnoremap <silent> <C-h> :-tabmove<CR>

"}}}

" プラグインマネージャーの設定{{{
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

execute 'set runtimepath^=' . s:dein_repo_dir

let s:toml = $DOTFILES_ROOT . '/.dein.toml'
let s:lazy_toml = $DOTFILES_ROOT . '/.dein_lazy.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

if has('vim_starting') && dein#check_install()
  call dein#install()
endif
"}}}

" neovim関連{{{
" if has('nvim')
  set guicursor=n:blinkon10,i-ci:ver50-blinkon10
  " " pyenvで指定したpythonを使用する
  " let $PATH = "~/.pyenv/shims:".$PATH

  " ruby用
  let g:ruby_host_prog = '~/.rbenv/shims/neovim-ruby-host'

  " neovim用pythonの設定
  " https://qiita.com/sigwyg/items/41630f8754c2028a7a9f
  let g:python_host_prog = $PYENV_ROOT . '/versions/neovim-2/bin/python'
  let g:python3_host_prog = $PYENV_ROOT . '/versions/neovim-3/bin/python'

  " プラグインマネージャーの設定
  let s:dein_dir = expand('~/.cache/dein')
  let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

  if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
  endif

  execute 'set runtimepath^=' . s:dein_repo_dir

  let s:toml = '~/.dein.toml'
  let s:lazy_toml = '~/.dein_lazy.toml'
  if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)
    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})
    call dein#end()
    call dein#save_state()
  endif

  if has('vim_starting') && dein#check_install()
   call dein#install()
  endif
  "" 補完のポップアップメニューの色 neovim Only
  " set pumblend=10
" endif

" deinの処理後でないと機能しない{{{
filetype plugin indent on
syntax enable

"" 補完のポップアップメニューの色
set termguicolors
highlight Pmenu ctermfg=white ctermbg=darkgray
highlight PmenuSel ctermfg=yellow ctermbg=black
highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=darkgray

highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE
highlight Folded ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE

"" colorscheme gruvbox用の設定
highlight comment ctermfg=242 guifg=darkcyan
"}}}

"}}}

" others{{{

if !has('gui_running')
  " CUIで入力された<S-CR>が拾えないので
  " iTerm2のキー設定を利用して特定の文字入力をmapする
  map ✠ <S-CR>
  nnoremap <CR> zo<CR>
  nnoremap <S-CR> zc<CR>
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
endif

" 文字削除時にクリップボードコピーしない
" nnoremap d "_d
" xnoremap d "_d
" xnoremap p "_dP
" 選択時に改行を含まない
vnoremap $ g_

" 形式変換
vnoremap camel :s/\%V\(_\\|-\)\(.\)/\u\2/g<CR>
vnoremap snake :s/\%V\([A-Z]\)/_\l\1/g<CR>
vnoremap kebab :s/\%V\([A-Z]\)/-\l\1/g<CR>

" Move current line to up/down
" Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
" When MacOS
" Ref: https://stackoverflow.com/questions/7501092/can-i-map-alt-key-in-vim
if has('macunix')
  " Option + J/K
  " ∆ == J
  " ˚ == K
  nnoremap ∆ :m .+1<CR>==
  nnoremap ˚ :m .-2<CR>==
  inoremap ∆ <Esc>:m .+1<CR>==gi
  inoremap ˚ <Esc>:m .-2<CR>==gi
  vnoremap ∆ :m '>+1<CR>gv=gv
  vnoremap ˚ :m '<-2<CR>gv=gv
endif

" Reload vimrc
command! Vimrc :source ~/.vimrc
" tmuxをDevModeにする
command! TmuxModeDev silent !tmux source-file ${DOTFILES_ROOT} . /.tmux/.tmux.dev.conf

" augroup GrepCmd
"   autocmd!
"   autocmd QuickFixCmdPost vim,grep,make if len(getqflist()) != 0 | cwindow | endif
" augroup END
autocmd QuickFixCmdPost *grep* copen

" Toggle quickfix
" if exists('g:__QUICKFIX_TOGGLE__')
"   finish
" endif
" let g:__QUICKFIX_TOGGLE__ = 1

function! ToggleQuickfix()
  let l:nr = winnr('$')
  cwindow
  let l:nr2 = winnr('$')
  if l:nr == l:nr2
      cclose
  endif
endfunction
nnoremap <script> <silent> <F4> :call ToggleQuickfix()<CR>

autocmd FileType vim setlocal foldmethod=marker

"" https://vim-jp.org/vim-users-jp/2009/10/08/Hack-84.html
" Save fold settings.
autocmd BufWritePost * if expand('%') != '' && &buftype !~ 'nofile' | mkview | endif
autocmd BufRead * if expand('%') != '' && &buftype !~ 'nofile' | silent! loadview | endif
" Don't save options.
set viewoptions-=option

" htmlで対応タグに移動する。
source $VIMRUNTIME/macros/matchit.vim

"}}}

" Local Setting{{{
if filereadable(expand('~/.vim/local.vim'))
  source ~/.vim/local.vim
endif
" }}}
