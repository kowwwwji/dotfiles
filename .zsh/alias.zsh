alias lg=lazygit
alias g=hub
#githubのローカルリポジトリに移動
alias gs='cd $(ghq root)/$(ghq list | fzf)'
#githubのリモートリポジトリをブラウズ
alias gsv='hub browse $(ghq list | fzf | cut -d "/" -f 2,3)'

alias brew="PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin brew"
alias ll='ls -lha'
alias vim=nvim
alias dc=docker-compose
alias re=rbenv
alias ar='function(){eval $(command assume-role $@);}'
alias tf=terraform
alias tm=tmux
alias relogin='exec $SHELL -l'
