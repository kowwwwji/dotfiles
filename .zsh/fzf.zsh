[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --reverse --border --cycle'
export FZF_DEFAULT_COMMAND='rg --hidden --ignore .git -g ""'
