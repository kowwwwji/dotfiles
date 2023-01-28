########################################
# tmux
########################################
if [[ -d "${HOME}/.tmux" ]]; then
  if [[ ! -d "${HOME}/.tmux/plugins" ]]; then
    mkdir ~/.tmux/plugins
    git clone 'https://github.com/tmux-plugins/tpm' "${HOME}/.tmux/plugins/tpm"
  fi
fi
function t(){
  tmux new-session -s $(basename $(pwd))
}
function dev(){
  tmux new-session -s $(basename $(pwd)) \; source-file ${DOTFILES_ROOT}/.tmux/.tmux.dev.conf
}

function pecoSelectTmuxSession(){
  local session="$(tmux list-sessions | fzf | cut -d : -f 1)"
  if [ -n "$session" ]; then
    BUFFER="tmux a -t $session"
    if [ -n "$TMUX" ]; then
      BUFFER="tmux switch -t $session"
    fi

    zle accept-line
  fi
}
zle -N pecoSelectTmuxSession
bindkey '^T' pecoSelectTmuxSession

