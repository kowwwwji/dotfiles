########################################
# デバッグ用
########################################
#zmodload zsh/zprof && zprof

########################################
# 各種設定ファイル
########################################
ZSH_HOME="${HOME}/.zsh"

if [ -d $ZSH_HOME -a -r $ZSH_HOME -a -x $ZSH_HOME ]; then
  for i in $ZSH_HOME/*; do
    # echo $i ## for Debug
    [[ ${i##*/} = *.zsh ]] &&
      [ \( -f $i -o -h $i \) -a -r $i ] && source $i
  done
fi

if [[ -f "$ZSH_HOME/.zsh_history" ]]; then
  HISTFILE="$ZSH_HOME/.zsh_history"
fi

GITHUB_CREDENTIAL_FILE=~/.config/.github_credentials
if [[ -f $GITHUB_CREDENTIAL_FILE ]]; then
  source $GITHUB_CREDENTIAL_FILE
fi

########################################
# 環境変数
########################################
export LANG=ja_JP.UTF-8
export LC_CTYPE=en_US.UTF-8
# export TERM=xterm-256color
export XDG_CONFIG_HOME=~/.config

# インストールしたものの読込
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) $path)

# 色を使用出来るようにする
autoload -Uz colors && colors

# emacs 風キーバインドにする
bindkey -e

# ヒストリの設定
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history
setopt share_history

# 単語の区切り文字を指定する
autoload -Uz select-word-style && select-word-style default

# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# プロンプト
########################################
# # 2行表示
# PROMPT="%{${fg[green]}%}[%n@%m %*]%{${reset_color}%} %~
# %# "
# SPROMPT="%r is correct? [n,y,a,e]: "

# autoload -Uz vcs_info

# # Gitの情報を表示
# zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
# zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

# function _update_vcs_info_msg() {
#   LANG=en_US.UTF-8 vcs_info
#   RPROMPT="${vcs_info_msg_0_}"
# }

# autoload -Uz add-zsh-hook
# add-zsh-hook precmd _update_vcs_info_msg

eval "$(starship init zsh)"

########################################
# オプション
########################################
setopt print_eight_bit      # 日本語ファイル名を表示可能にする
setopt no_beep
setopt no_flow_control      # 履歴検索時にctrl+s で1個前の検索に戻れるようにする。
setopt ignore_eof           # Ctrl+Dでzshを終了しない
setopt interactive_comments # '#' 以降をコメントとして扱う
setopt auto_cd              # ディレクトリ名だけでcdする
setopt auto_pushd
setopt pushd_ignore_dups
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt extended_glob        # 高機能なワイルドカード展開を使用する
setopt correct              # 入力したコマンド名が間違っている場合には修正
setopt list_packed          # 補完候補を詰めて表示する設定

########################################
# OS 別の設定
########################################
case ${OSTYPE} in
  darwin*)
    #Mac用の設定
    export CLICOLOR=1
    alias ls='ls -G -F'
    ;;
  linux*)
    #Linux用の設定
    alias ls='ls -F --color=auto'
    ;;
esac

########################################
# 言語別の設定
########################################
# python用の設定
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# node
# nvmコマンドを使用したときのみnvm.shをロードするようにする。
# https://qiita.com/uasi/items/80865646607b966aedc8
export NVM_DIR="$HOME/.nvm"
NODE_VER=`cat ${NVM_DIR}/alias/default`
NODE_DIR=${NVM_DIR}/versions/node/${NODE_VER}
export NODE_BIN=${NODE_DIR}/bin
PATH=${NODE_BIN}:$PATH
MANPATH=${NODE_DIR}/share/man:$MANPATH
export NODE_PATH=${NODE_DIR}/lib/node_modules
NODE_PATH=${NODE_PATH:A}
function nvm() {
    unset -f nvm
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
    nvm "$@"
}

# Ruby
export RBENV_ROOT="$HOME/.rbenv"
eval "$(rbenv init -)"

# Go
export GOENV_ROOT="$HOME/.goenv"
eval "$(goenv init -)"
export GOPATH=~/.go
export PATH=$GOPATH/bin:$PATH

# PATHの重複を削除
typeset -U PATH

########################################
# デバッグ用
########################################
# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi

cd-fzf-dein () {
  local cache_vim json plugin
  cache_vim="$HOME/.cache/dein/cache_nvim"
  json="$(sed 's@\({\|,\)\(\w\+\):@\1"\2":@g' < $cache_vim)"
  plugin="$(jq -r '.[0] | keys | .[]' <<< "$json" | fzf)"
  # cd "$(jq -r ".[0].[\"$plugin\"].path" <<< "$json")"
  cd "$(jq -r ".[0].\"$plugin\".path" <<< "$json")"
}
