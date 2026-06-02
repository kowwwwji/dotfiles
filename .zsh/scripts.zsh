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
    echo "===gcloud==="
    gcloud config configurations activate "$config" --quiet

    # kubectx
    local project=$(gcloud config get-value project --quiet)
    local context="gke_${project}_asia-northeast1_${project}-cluster"
    if kubectl config get-contexts -o name 2>/dev/null | grep -qx "$context"; then
      echo ""
      echo "===kubectx==="
      kubectx "$context"
    fi

    # opentofu (configuration名の末尾をworkspace名とする: ${PROJECT_NAME}-dev -> dev)
    local workspace="${config##*-}"
    if [ -n "$(print -l ./*.tf(N))" ] && tofu workspace list 2>/dev/null | sed 's/^[* ]*//' | grep -qx "$workspace"; then
      echo ""
      echo "===opentofu==="
      tofu workspace select "$workspace"
      echo "Activated [${workspace}]."
    fi
  fi
}
