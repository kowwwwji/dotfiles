########################################
# デバッグ用
########################################
#zmodload zsh/zprof && zprof


########################################
# 各種設定ファイル
#########################################
if [[ -f "${HOME}/.zsh_alias" ]]; then
  source "${HOME}/.zsh_alias"
fi

if [[ -f "${HOME}/.zsh_alias" ]]; then
  HISTFILE="${HOME}/.zsh_history"
fi

GITHUB_CREDENTIAL_FILE=~/.config/.github_credentials
if [ -e $GITHUB_CREDENTIAL_FILE ]; then
  source $GITHUB_CREDENTIAL_FILE
fi
########################################
# 環境変数
########################################
export LANG=ja_JP.UTF-8
export LC_CTYPE=en_US.UTF-8
export TERM=xterm-256color

# インストールしたものの読込
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) $path)

# 色を使用出来るようにする
autoload -Uz colors
colors

# emacs 風キーバインドにする
bindkey -e

# ヒストリの設定
HISTSIZE=50000
SAVEHIST=50000
setopt inc_append_history
setopt share_history

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# 補完
########################################
# zsh-completionsを追加
if type brew &>/dev/null; then
  fpath=($(brew --prefix)/share/zsh-completions(N-/) $fpath)
fi

# 補完機能を有効にする
autoload -Uz compinit
compinit -u

# Terraform用
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

## 先方予測機能を有効
#autoload predict-on
#predict-on

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' \
  command-path /usr/local/sbin /usr/local/bin \
    /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# fzf completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

########################################
# プロンプト
########################################
# 2行表示
PROMPT="%{${fg[green]}%}[%n@%m]%{${reset_color}%} %~
%# "
SPROMPT="%r is correct? [n,y,a,e]: "

autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# Gitの情報を表示
zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

function _update_vcs_info_msg() {
  LANG=en_US.UTF-8 vcs_info
  RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg


########################################
# オプション
########################################
# 日本語ファイル名を表示可能にする
setopt print_eight_bit
# beep を無効にする
setopt no_beep
# フローコントロールを無効にする
setopt no_flow_control
# Ctrl+Dでzshを終了しない
setopt ignore_eof
# '#' 以降をコメントとして扱う
setopt interactive_comments
# ディレクトリ名だけでcdする
setopt auto_cd
# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups
# 同時に起動したzshの間でヒストリを共有する
setopt share_history
# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space
# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks
# 高機能なワイルドカード展開を使用する
setopt extended_glob
# 入力したコマンド名が間違っている場合には修正
setopt correct
# 補完候補を詰めて表示する設定
setopt list_packed

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
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# node
# nvmコマンドを使用したときのみnvm.shをロードするようにする。
export NVM_DIR="$HOME/.nvm"
#nvm() {
#    unset -f nvm
#    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
#    nvm "$@"
#}
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Ruby
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

# Go
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

########################################
# デバッグ用
########################################
#if (which zprof > /dev/null 2>&1) ;then
#  zprof
#fi

