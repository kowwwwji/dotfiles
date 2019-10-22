""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 画面表示の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" colorscheme desert
syntax enable
set number         " 行番号を表示する
set cursorline     " カーソル行の背景色を変える
set laststatus=2   " ステータス行を常に表示
set cmdheight=2    " メッセージ表示欄を2行確保
set showmatch      " 対応する括弧を強調表示
set helpheight=999 " ヘルプを画面いっぱいに開く
set list           " 不可視文字を表示

" 不可視文字の表示記号指定
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮

" カーソルの形
if has('vim_starting')
  " 挿入モード時に非点滅の縦棒タイプのカーソル
  let &t_SI .= "\e[6 q"
  " ノーマルモード時に非点滅のブロックタイプのカーソル
  let &t_EI .= "\e[2 q"
  " 置換モード時に非点滅の下線タイプのカーソル
  let &t_SR .= "\e[4 q"
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" カーソル移動関連の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set backspace=indent,eol,start " Backspaceキーの影響範囲に制限を設けない
set whichwrap=b,s,h,l,<,>,[,]  " 行頭行末の左右移動で行をまたぐ
set scrolloff=8                " 上下8行の視界を確保
set sidescrolloff=16           " 左右スクロール時の視界を確保
set sidescroll=1               " 左右スクロールは一文字づつ行う

" easy-motion用
let g:EasyMotion_leader_key = '<Space><Space>'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ファイル処理関連の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set confirm    " 保存されていないファイルがあるときは終了前に保存確認
set hidden     " 保存されていないファイルがあるときでも別のファイルを開くことが出来る
set autoread   " 外部でファイルに変更がされた場合は読みなおす
set nobackup   " ファイル保存時にバックアップファイルを作らない
set noswapfile " ファイル編集中にスワップファイルを作らない

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 検索/置換の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hlsearch   " 検索文字列をハイライトする
hi Search ctermbg=Red
hi Search ctermfg=White
set incsearch  " インクリメンタルサーチを行う
set ignorecase " 大文字と小文字を区別しない
set smartcase  " 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
set wrapscan   " 最後尾まで検索を終えたら次の検索で先頭に移る
set gdefault   " 置換の時 g オプションをデフォルトで有効にする
" 常に very magic モードにする
nnoremap / /\v

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" タブ/インデントの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab     " タブ入力を複数の空白入力に置き換える
set tabstop=2     " 画面上でタブ文字が占める幅
set shiftwidth=2  " 自動インデントでずれる幅
set softtabstop=2 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent    " 改行時に前の行のインデントを継続する
set smartindent   " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 動作環境との統合関連の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OSのクリップボードをレジスタ指定無しで Yank, Put 出来るようにする
set clipboard=unnamed,unnamedplus
" マウスの入力を受け付ける
set mouse=a
" Windows でもパスの区切り文字を / にする
set shellslash
" インサートモードから抜けると自動的にIMEをオフにする
set iminsert=0
set imsearch=-1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" コマンドラインの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" コマンドラインモードでTABキーによるファイル名補完を有効にする
set wildmenu wildmode=list:longest,full
" コマンドラインの履歴を10000件保存する
set history=10000

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ビープの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"ビープ音すべてを無効にする
set visualbell t_vb=
set noerrorbells        "エラーメッセージの表示時にビープを鳴らさない

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" コロンでコマンドモードに入るようにする。
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap ;  :
nnoremap :  ;
vnoremap ;  :
vnoremap :  ;

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" インサートモードで移動
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
inoremap <c-h> <left>
inoremap <c-l> <right>
inoremap <c-k> <up>
inoremap <c-j> <down>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" pyenvで指定したpythonを使用する
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let $PATH = "~/.pyenv/shims:".$PATH

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" プラグイン設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
let g:python3_host_prog = $PYENV_ROOT . '/shims/python3'

if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

execute 'set runtimepath^=' . s:dein_repo_dir

let s:toml = '~/.dein.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml])
  call dein#load_toml(s:toml)
  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
 call dein#install()
endif

filetype plugin indent on
syntax enable

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Previm用の設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:previm_open_cmd = 'open -a Google\ Chrome'
augroup PrevimSettings
  autocmd!
  autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
  nnoremap <silent> <C-m> :PrevimOpen<CR>
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" open-brawser用の設定 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:netrw_nogx = 1
augroup OpenBrowserSettings
  nmap gx <Plug>(openbrowser-smart-search)
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vueファイルのときのsyntax設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 autocmd FileType vue syntax sync fromstart
  
 " deoplete.vim
 let g:deoplete#enable_at_startup = 1

 " <TAB>: completion.
 inoremap <silent><expr> <TAB>
       \ pumvisible() ? "\<C-n>" :
       \ <SID>check_back_space() ? "\<TAB>" :
       \ deoplete#manual_complete()

 function! s:check_back_space() abort
   let col = col('.') - 1
   return !col || getline('.')[col - 1]  =~ '\s'
 endfunction 

 " <S-TAB>: completion back.
 inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<C-h>"
 
 " <BS>: close popup and delete backword char.
 inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"
 
 " <CR>: close popup and save indent.
 inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
 function! s:my_cr_function() abort
   return deoplete#cancel_popup() . "\<CR>"
 endfunction
 
 " neosnippet.vim
 "imap <C-i>     <Plug>(neosnippet_expand_or_jump)
 "smap <C-i>     <Plug>(neosnippet_expand_or_jump)
 "xmap <C-i>     <Plug>(neosnippet_expand_target)
 let g:neosnippet#enable_snipmate_compatibility = 1
 let g:neosnippet#enable_completed_snippet = 1
 let g:neosnippet#expand_word_boundary = 1
 
 " LanguageClient-neovim
 set hidden
 let g:LanguageClient_serverCommands = {
     \ 'vue': ['vls'],
     \ }
 nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
 nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
 nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
