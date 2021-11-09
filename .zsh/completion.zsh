#######################################
# 補完
#######################################
# zsh-completionsを追加 *fpathはzshが自動で読み込んでくれるパス
if type brew &>/dev/null; then
  fpath=($(brew --prefix)/share/zsh-completions(N-/) $fpath)
fi

# 補完機能を有効にする
autoload -Uz compinit && compinit -C

# Terraform用
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# 先方予測機能
# autoload -Uz predict-on && predict-on

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
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
# bindkey '^S' fzf-file-widget

