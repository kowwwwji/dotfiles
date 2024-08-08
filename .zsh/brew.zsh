NOT_INSTALL_MODULE="";
if type direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
else
  $NOT_INSTALL_MODULE="direnv"
fi

if type asdf &>/dev/null; then
  source $(brew --prefix asdf)/libexec/asdf.sh
  NODE_BIN=$(asdf which node)
  source ~/.asdf/plugins/java/set-java-home.zsh

  # golang
  export ASDF_GOLANG_MOD_VERSION_ENABLED=true
else
  $NOT_INSTALL_MODULE+=", asdf"
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
  # History menu.
  zstyle ':autocomplete:history-search-backward:*' list-lines 16
else
  $NOT_INSTALL_MODULE+=", sheldon"
fi

if [ -n "$NOT_INSTALL_MODULE" ]; then
  echo "以下モジュールがインストールされていません"
  echo $NOT_INSTALL_MODULE
fi

