#!/bin/zsh

DOTFILES_ROOT=`ghq root`/github.com/kowwwwji/dotfiles

for i in ./.* ; do
  [[ -f $i ]] \
    && ln -nfs ${DOTFILES_ROOT}/${i##./} ${HOME}/${i##./}
done;
mkdir -p ${HOME}/.config/vim/
ln -nfs ${DOTFILES_ROOT}/.config/vim/plugins ${HOME}/.config/vim/
ln -nfs ${DOTFILES_ROOT}/.config/vim/UltiSnips ${HOME}/.config/vim/
ln -nfs ${DOTFILES_ROOT}/.config/vim/coc-settings.json ${HOME}/.config/vim/coc-settings.json
ln -nfs ${DOTFILES_ROOT}/.config/starship.toml ${HOME}/.config/starship.toml
ln -nfs ${DOTFILES_ROOT}/.config/lazydocker/config.yml ${HOME}/.config/lazydocker/config.yml
ln -nfs ${DOTFILES_ROOT}/.config/lazygit/config.yml ${HOME}/.config/lazygit/config.yml
ln -nfs ${DOTFILES_ROOT}/.config/memo ${HOME}/.config/
ln -nfs ${DOTFILES_ROOT}/.config/nvim ${HOME}/.config/
ln -nfs ${DOTFILES_ROOT}/.config/sheldon ${HOME}/.config/
ln -nfs ${DOTFILES_ROOT}/.config/karabiner/karabiner.json ${HOME}/.config/karabiner/karabiner.json
ln -nfs ${DOTFILES_ROOT}/.config/karabiner/assets/complex_modifications/ ${HOME}/.config/karabiner/assets/complex_modifications/

# # linkだとagがうまく動かないのでcp
# cp -f ${DOTFILES_ROOT}/.agignore ${HOME}/.agignore

mkdir ${HOME}/.config/git/ && touch ${HOME}/.config/git/.gitconfig.local
mkdir ${HOME}/.ssh && touch ${HOME}/.ssh/config

ln -nfs ${DOTFILES_ROOT}/.zsh $HOME
ln -nfs ${DOTFILES_ROOT}/.scripts $HOME

VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
if [[ -d $VSCODE_USER_DIR ]]; then
  for i in ./.vscode/*; do
    cp ${DOTFILES_ROOT}/${i#./} "$VSCODE_USER_DIR${i##./.vscode}"
  done
fi

TPM_ROOT=${HOME}/.tmux/plugins/tpm
[[ ! -e $TPM_ROOT ]] && git clone https://github.com/tmux-plugins/tpm $TPM_ROOT
ln -nfs ${DOTFILES_ROOT}/.tmux/.tmux.dev.conf ${HOME}/.tmux
