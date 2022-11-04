cd-fzf-dein () {
  local cache_vim json plugin
  cache_vim="$HOME/.cache/dein/cache_nvim"
  json="$(sed 's@\({\|,\)\(\w\+\):@\1"\2":@g' < $cache_vim)"
  plugin="$(jq -r '.[0] | keys | .[]' <<< "$json" | fzf)"
  # cd "$(jq -r ".[0].[\"$plugin\"].path" <<< "$json")"
  cd "$(jq -r ".[0].\"$plugin\".path" <<< "$json")"
}

init-vimspector () {
  if [[ $# = 1 ]]; then
    FileType=$1
    cp $DOTFILES_ROOT/.template/vimspector/$FileType.json .vimspector.json
  else
    echo "require FileType"
  fi
}
