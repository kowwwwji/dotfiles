########################################
# 環境変数
########################################
if [ ghq ];then
  export DOTFILES_ROOT=`ghq root`/github.com/kowwwwji/dotfiles
fi
export LANG=ja_JP.UTF-8
export LC_CTYPE=en_US.UTF-8
export XDG_CONFIG_HOME=~/.config
HISTSIZE=50000
SAVEHIST=50000

# 色を使用出来るようにする
autoload -Uz colors && colors

# emacs 風キーバインドにする
bindkey -e

# 単語の区切り文字を指定する
autoload -Uz select-word-style && select-word-style default

# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

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
setopt inc_append_history
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
# 各種設定ファイル読込
########################################
# デバッグ用
#zmodload zsh/zprof && zprof

# インストールしたものの読込
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) $path)
# 独自スクリプト読み込み
path=(~/.scripts(N-/) $path)

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

# PATHの重複を削除
typeset -U PATH

eval "$(direnv hook zsh)"
export MANPAGER='nvim +Man!'

source /opt/homebrew/opt/asdf/libexec/asdf.sh
NODE_BIN=$(asdf which node)
source ~/.asdf/plugins/java/set-java-home.zsh

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

eval "$(sheldon source)"

# デバッグ用
# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi
