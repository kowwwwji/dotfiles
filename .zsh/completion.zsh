#######################################
# 補完
#######################################
# zsh-completionsを追加 *fpathはzshが自動で読み込んでくれるパス
if type brew &>/dev/null; then
  fpath=($(brew --prefix)/share/zsh/site-functions(N-/) $fpath)
  fpath=(~/.docker/completions $fpath)
fi

# mise補完
if type mise &>/dev/null; then
  eval "$(mise completion zsh)"
fi

# 補完機能を有効にする
autoload -Uz compinit && compinit -C

# Terraform用
if type terraform &>/dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v terraform)" terraform
fi

# OpenTofu用（zsh 用の補完関数は配布されておらず、コマンド自身が候補を返す Go 方式のため complete -C で登録）
if type tofu &>/dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v tofu)" tofu
fi

# 先方予測機能 zinitを使用してるためOFF
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

# Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# bun
[ -s "/Users/k-sakamoto/.bun/_bun" ] && source "/Users/k-sakamoto/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

