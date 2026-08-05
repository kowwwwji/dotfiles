# 自己更新する cask（Chrome, Discord 等 auto_updates true）を brew upgrade / brew bundle の
# 更新対象から外す。アプリ側の自動更新と brew の管理バージョンが乖離した状態で brew が
# 上書きしようとすると衝突する（Caskroom への退避失敗や sudo 要求）ため、自己更新に任せる。
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1

NOT_INSTALL_MODULE="";
if type direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
else
  $NOT_INSTALL_MODULE="direnv"
fi

if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
  # golang: go install でインストールしたバイナリを使えるようにする
  export PATH="$(go env GOPATH)/bin:$PATH"
else
  $NOT_INSTALL_MODULE+=", mise"
fi

# Sheldon関連
if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
  POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
  # zsh-autocompleteの設定
  LISTMAX=1000 # completionが多すぎるときに出る確認メッセージを出さないようにしている
  zstyle ":completion:*:commands" rehash 1
  zstyle '*:compinit' arguments -D -i -u -C -w
  bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
  bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
  bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
  # all Tab widgets
  zstyle ':autocomplete:*complete*:*' insert-unambiguous yes
  # all history widgets
  zstyle ':autocomplete:*history*:*' insert-unambiguous yes
  zstyle ':autocomplete:*' add-space executables aliases functions builtin
  # ~を/Users/...に展開しない
  zstyle ':completion:*' completer _complete _ignored
  # History menu.
  zstyle ':autocomplete:history-search-backward:*' list-lines 16
else
  $NOT_INSTALL_MODULE+=", sheldon"
fi

if [ -n "$NOT_INSTALL_MODULE" ]; then
  echo "以下モジュールがインストールされていません"
  echo $NOT_INSTALL_MODULE
fi

