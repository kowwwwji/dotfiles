# lazy
alias lzg=lazygit
alias lzd=lazydocker
alias lzs=lazysql

# git
alias g=gh

alias ghs='ghqSearch'
function ghqSearch(){
  CD_DIR=`ghq list | fzf --query=$1 --preview "ls -a1p $(ghq root)/{}"`
  [[ $CD_DIR ]] && cd $(ghq root)/$CD_DIR
}
alias gws='gwqSwitch'
# gwq の worktree を fzf で選んで移動する。
# tmux 内なら同名 window に切り替え（無ければ作成）、tmux 外なら cd する。
function gwqSwitch(){
  if [[ -n $TMUX ]]; then
    gwq-window "$@"
  else
    local wt_path
    wt_path=$(gwq get "$@") || return
    [[ -n $wt_path ]] && cd "$wt_path"
  fi
}

alias ll='ls -lha'
# Make and change directory at once
alias mkcd='_(){ mkdir -p $1; cd $1; }; _'
# fast find
alias ff='find . -name $1'
alias nv=nvim
alias dc='docker compose'
alias re=rbenv
alias ar='function(){eval $(command assume-role $@);}'
alias tf=terraform
alias tm=tmux
alias relogin='exec $SHELL -l'
alias vg=vagrant

# Npm alias
alias np='npm'
alias npi='npm install'
alias npis='npm install --save'
alias npig='npm install -g'
alias nps='npm start'
alias npr='npm run'
alias npd='npm run dev'
alias npt='npm run test'

alias gc='gcloud'
alias mac-notify='terminal-notifier -title "iTerm2" -sound Glass -message $1 '
alias gitroot='git rev-parse --show-toplevel'
alias cl=claude
alias todo='memo e ~/ghq/github.com/kowwwwji/memo/README.md'
