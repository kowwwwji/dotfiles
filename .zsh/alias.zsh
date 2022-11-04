alias lg=lazygit
alias g=gh
# ローカルリポジトリに移動
alias gs='ghqSearch'
function ghqSearch(){
  CD_DIR=`ghq list | fzf --query=$1 --preview "ls -a1p $(ghq root)/{}"`
  [[ $CD_DIR ]] && cd $(ghq root)/$CD_DIR
}

alias ll='ls -lha'
alias vim=nvim
alias dc=docker-compose
alias re=rbenv
alias ar='function(){eval $(command assume-role $@);}'
alias tf=terraform
alias tm=tmux
alias relogin='exec $SHELL -l'
alias vg=vagrant
