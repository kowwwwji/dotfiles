#!/bin/zsh

DOTFILES_ROOT=`ghq root`/github.com/kowwwwji/dotfiles

for i in ./.* ; do
  [[ -f $i ]] \
    && ln -s ${DOTFILES_ROOT}/${i##./} ${HOME}/${i##./}
done;
mkdir -p ${HOME}/.config/nvim/
ln -s ${HOME}/.vimrc ${HOME}/.config/nvim/init.vim
ln -s ${DOTFILES_ROOT}/.config/nvim/plugins ${HOME}/.config/nvim/
ln -s ${DOTFILES_ROOT}/.config/nvim/UltiSnips ${HOME}/.config/nvim/
ln -s ${DOTFILES_ROOT}/.config/nvim/coc-settings.json ${HOME}/.config/nvim/coc-settings.json
ln -s ${DOTFILES_ROOT}/.config/starship.toml ${HOME}/.config/starship.toml
ln -s ${DOTFILES_ROOT}/.config/memo ${HOME}/.config/memo/

mkdir ${HOME}/.config/git/ && touch ${HOME}/.config/git/.gitconfig.local
mkdir ${HOME}/.ssh && touch ${HOME}/.ssh/config

ln -s ${DOTFILES_ROOT}/.zsh $HOME
ln -s ${DOTFILES_ROOT}/.scripts $HOME

VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
if [[ -d $VSCODE_USER_DIR ]]; then
  for i in ./.vscode/*; do
    cp ${DOTFILES_ROOT}/${i#./} "$VSCODE_USER_DIR${i##./.vscode}"
  done
fi

TPM_ROOT=${HOME}/.tmux/plugins/tpm
[[ ! -e $TPM_ROOT ]] && git clone https://github.com/tmux-plugins/tpm $TPM_ROOT
ln -s ${DOTFILES_ROOT}/.tmux/.tmux.dev.conf ${HOME}/.tmux
