function cd-fzf-dein () {
  local cache_vim json plugin
  cache_vim="$HOME/.cache/dein/cache_nvim"
  json="$(sed 's@\({\|,\)\(\w\+\):@\1"\2":@g' < $cache_vim)"
  plugin="$(jq -r '.[0] | keys | .[]' <<< "$json" | fzf)"
  # cd "$(jq -r ".[0].[\"$plugin\"].path" <<< "$json")"
  cd "$(jq -r ".[0].\"$plugin\".path" <<< "$json")"
}

function init-vimspector () {
  if [[ $# = 1 ]]; then
    FileType=$1
    cp $DOTFILES_ROOT/.template/vimspector/$FileType.json .vimspector.json
  else
    echo "require FileType"
  fi
}

# GoogleCLoudとkubectlの環境を変える
function gcs() {
  local config=$(gcloud config configurations list --format='value(name)' | fzf)
  if [ -n "$config" ]; then
    gcloud config configurations activate "$config" 
    echo ""
    local project=$(gcloud config get-value project --quiet)
    kubectx gke_"$project"_asia-northeast1_"$project"-cluster
  fi
}
