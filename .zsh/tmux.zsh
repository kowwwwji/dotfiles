########################################
# tmux
########################################
if [[ -d "${HOME}/.tmux" ]]; then
  if [[ ! -d "${HOME}/.tmux/plugins" ]]; then
    mkdir ~/.tmux/plugins
    git clone 'https://github.com/tmux-plugins/tpm' "${HOME}/.tmux/plugins/tpm"
  fi
fi
# git ブランチ名（取得できなければカレントディレクトリ名）を返す
function _tmux_branch_name(){
  local name
  name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [[ -z $name || $name == HEAD ]] && name=$(basename "$PWD")
  print -r -- "$name"
}
function t(){
  tmux new-session -s "$(basename "$(pwd)")" -n "$(_tmux_branch_name)"
}
function dev(){
  tmux new-session -s "$(basename "$(pwd)")" -n "$(_tmux_branch_name)" \; source-file ${DOTFILES_ROOT}/.tmux/.tmux.dev.conf
}

# tmux 内では window 名を現在の git ブランチ名（無ければディレクトリ名）に追従させる
function _tmux_rename_window_to_branch(){
  [[ -n $TMUX ]] && tmux rename-window "$(_tmux_branch_name)"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _tmux_rename_window_to_branch
add-zsh-hook chpwd _tmux_rename_window_to_branch

function pecoSelectTmuxSession(){
  # セッション単位で選択。各行に通知(ベル/サイレント)のあるwindowを "index:名前" で表示
  local line session
  line="$(
    tmux list-sessions -F '#{session_name}' | grep -v '^popup$' | while read -r s; do
      # while はパイプ右側=サブシェルなので local 不要(zshでは local が alerts='' を出力してしまう)
      alerts=$(tmux list-windows -t "$s" -f '#{||:#{window_bell_flag},#{window_silence_flag}}' -F '#{window_index}:#{window_name}' 2>/dev/null | paste -sd ' ' -)
      # セッション名と通知表示はタブ区切り(表示は空白に見える/抽出はタブで行う)
      if [ -n "$alerts" ]; then
        printf '%s\t󱅫 %s\n' "$s" "$alerts"
      else
        printf '%s\n' "$s"
      fi
    done | fzf
  )"
  if [ -n "$line" ]; then
    session="${line%%$'\t'*}"
    BUFFER="tmux a -t $session"
    if [ -n "$TMUX" ]; then
      BUFFER="tmux switch -t $session"
    fi

    zle accept-line
  fi
}
zle -N pecoSelectTmuxSession
bindkey '^T' pecoSelectTmuxSession

