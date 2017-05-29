# Created by newuser for 5.3.1
####################
# key binding
####################

# emacs binding
bindkey -e

####################
# Alias
####################
if [[ -f "${HOME}/.zsh_alias" ]]; then
  source "${HOME}/.zsh_alias"
fi

####################
# path
####################

# remove duplicate path
typeset -U path cdpath fpath manpath

# local utils
path=(${HOME}/bin(N-/) $path)

# rsense
path=($path ${HOME}/rsense-0.3/bin(N-/))

# /usr/local/bin
path=(/usr/local/bin(N-/) $path)

####################
# Completion
####################

# autoload func path
if type brew &>/dev/null; then
  fpath=($(brew --prefix)/share/zsh/site-functions(N-/) $fpath)
fi

#fpath=(${ANTIBODY_HOME}/zsh-users-zsh-completions/src(N-/) $fpath)

# zsh functions
#fpath=(${HOME}/.zsh/functions(N-/) $fpath)
#function() {
#  local file
#  for file in ${HOME}/.zsh/functions/*(N-.); do
#    local func_name="${file:t}"
#    autoload -Uz -- "$func_name"
#    zle -N -- "$func_name"
#  done
#}

# enable completion
autoload -Uz compinit
compinit # also compinit -u

#zstyle ':completion:*' completer _oldlist _complete
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# specify ignored patterns whene completing
# fignore=(.sh)

# specify confirm message when completing
# LISTMAX=20

#cdpath=(~)

autoload -Uz add-zsh-hook

####################
# history
####################

# not history command prefixed with space
setopt hist_ignore_space

# no history history command
setopt hist_no_store

# history file
HISTFILE="${HOME}/.zsh_history"

# history file size
HISTSIZE=40000

# saveする量
SAVEHIST=40000

# no memory duplicate history
setopt hist_ignore_dups
setopt hist_ignore_all_dups

# delete unnececally space
setopt hist_reduce_blanks

# share history file
setopt share_history

# history zsh start and end
setopt EXTENDED_HISTORY

# append history file
setopt append_history

####################
# cd
####################

# change directory when entering directory name only
setopt auto_cd

# automatical register current directory in directory stack
setopt auto_pushd

# not register duplicate directory name in directory stack
setopt pushd_ignore_dups

# cdr
autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 200

####################
# PROMPT
####################

# PROMPT  -> left prompt
# RPROMPT -> right prompt
# PROMPT2 -> prompt when displaying 2 line
# SPROMPT -> prompt when entering error command

# enable color prompt
#autoload -U colors; colors
# prompt theme
#autoload -U promptinit; promptinit
# see prompt preview -> prompt -p <theme>
# see current theme -> prompt -c
#prompt walters

# use pcre-compatible regexp
#setopt re_match_pcre
# eval prompt when showing prompt
#setopt prompt_subst

# prompt
# %n -> user name
# %m -> hostname
# %~ -> current directory(home directory is ~)
# %(1,#,$)
# %f%b same as %{${reset_color}%}?
#if [[ -n "$SSH_TTY" ]]; then
#  _ssh_tty="@$(echo "$SSH_TTY" | grep -oE 's[0-9]+')"
#fi
#if [[ -n "$AWS_SESSION_TOKEN" ]]; then
#  _aws="aws"
#fi
#PROMPT='%n${_ssh_tty}$([[ -n "$AWS_SESSION_TOKEN" ]] && echo %{$fg_bold[red]%}@aws%{${reset_color}%}) %F{blue}%~%f%b $(-zsh-git-prompt)[%?]'$'\n''%(!,#,$) '

####################
# Misc Settings
####################

# locale
if ! [[ "$(locale)" =~ 'en_US\.UTF-8' ]]; then
  export LC_ALL="en_US.UTF-8"
  export LANG="en_US.UTF-8"
fi

# ls color
if [[ "$OSTYPE" =~ "darwin*" ]]; then
  export CLICOLOR=1
fi

# editor
if type nvim &>/dev/null; then
  export EDITOR="nvim"
elif type vim &>/dev/null; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi

# XDG_CONFIG
export XDG_CONFIG_HOME="${HOME}/.config"

# use zed
autoload zed

# use zmv
autoload zmv
alias zmv="noglob zmv"

# use zargs
autoload zargs

# extended globbing
setopt extended_glob

# sort matched value
setopt numericglobsort

setopt correct

# recognize variable contained abs path as directory name
setopt cdable_vars

# remove rprompt
#setopt transient_rprompt

# display packed list
setopt list_packed

setopt list_types

# not display prompt when completing command
setopt always_last_prompt

# one tab key
#setopt menu_complete

# ignore case-sensitive matches when globbing
#unsetopt case_glob

# match dotted files when globbing
#setopt glob_dots

# sort matched value whne globbing
setopt numeric_glob_sort

# run-help builtin command
# not work?
# [[ -n $(alias run-help) ]] && unalias run-help
# autoload run-help

# show time command outputs if command executing time exceeds 1 sec
REPORTTIME=1

# auto-fu.zsh
if [[ -f "${HOME}/.zsh/plugin/auto-fu.zsh/auto-fu.zsh" ]]; then
  source "${HOME}/.zsh/plugin/auto-fu.zsh/auto-fu.zsh"
  zle-line-init() {
    auto-fu-init
  }
  zle -N zle-line-init
fi

# w3m
if [[ -x "$(which w3m 2>/dev/null)" ]]; then
  export HTTP_HOME="http://www.google.com"
fi

# direnv
if [[ -x "$(which direnv 2>/dev/null)" ]]; then
  eval "$(direnv hook zsh)"
fi

# nvm
if [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
  source "${HOME}/.nvm/nvm.sh"
fi
if [[ -f "${HOME}/.nvm/bash_completion" ]]; then
  source "${HOME}/.nvm/bash_completion"
fi

# pwd.sh
if [[ -x "$(which pwd.sh 2>/dev/null)" ]]; then
  export PWDSH_SAFE="${HOME}/.pwd.sh.safe"
fi

# prevent duplicate path
if [[ -n "$TMUX" || -n "$SSH_TTY" ]]; then
  # rbenv
  if type rbenv &>/dev/null; then
    eval "$(rbenv init -)"
  fi

  # pyenv
  if type pyenv &>/dev/null; then
    eval "$(pyenv init -)";
    eval "$(pyenv virtualenv-init -)"
#   export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  fi

  # plenv
  if type plenv &>/dev/null; then
    eval "$(plenv init -)"
  fi

# # autoload general-env
# if type pyenv &>/dev/null && type pyenv-virtualenv &>/dev/null; then
#   if [[ "$(pyenv virtualenvs)" =~ 'general-env' ]]; then
#     pyenv activate general-env
#   fi
# fi

  # phpbrew
  if [[ -f "${HOME}/.phpbrew/bashrc" ]]; then
    source "${HOME}/.phpbrew/bashrc"
  fi
fi

# workaround:
# set shell environment
if type tmux &>/dev/null && [[ -n "$TMUX" ]]; then
  tmux set-environment -g PATH "$PATH"
fi
