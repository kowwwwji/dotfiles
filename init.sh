#!/bin/zsh

DOTFILES_ROOT=$(ghq root)/github.com/kowwwwji/dotfiles

# ドットファイルのシンボリックリンク作成
for i in ./.* ; do
  [[ "$i" == "./." || "$i" == "./.." || "$i" == "./init.sh" ]] && continue
  [[ -f "$i" ]] && ln -nfs "${DOTFILES_ROOT}/${i##./}" "${HOME}/${i##./}"
done

# vim
mkdir -p "${HOME}/.config/vim/"
ln -nfs "${DOTFILES_ROOT}/.config/vim/plugins" "${HOME}/.config/vim/"
ln -nfs "${DOTFILES_ROOT}/.config/vim/UltiSnips" "${HOME}/.config/vim/"
ln -nfs "${DOTFILES_ROOT}/.config/vim/coc-settings.json" "${HOME}/.config/vim/coc-settings.json"

# lazy
mkdir -p "${HOME}/.config/lazydocker"
mkdir -p "${HOME}/.config/lazygit"
ln -nfs "${DOTFILES_ROOT}/.config/lazydocker/config.yml" "${HOME}/.config/lazydocker/config.yml"
ln -nfs "${DOTFILES_ROOT}/.config/lazygit/config.yml" "${HOME}/.config/lazygit/config.yml"
ln -nfs "${DOTFILES_ROOT}/.config/lazygit/scripts" "${HOME}/.config/lazygit/"

ln -nfs "${DOTFILES_ROOT}/.config/nvim" "${HOME}/.config/"
ln -nfs "${DOTFILES_ROOT}/.config/sheldon" "${HOME}/.config/"
ln -nfs "${DOTFILES_ROOT}/.config/wezterm" "${HOME}/.config/"

mkdir -p "${HOME}/.config/karabiner/assets"
ln -nfs "${DOTFILES_ROOT}/.config/karabiner/karabiner.json" "${HOME}/.config/karabiner/karabiner.json"
ln -nfs "${DOTFILES_ROOT}/.config/karabiner/assets/complex_modifications" "${HOME}/.config/karabiner/assets/complex_modifications"

mkdir -p "${HOME}/.config/git/"
touch "${HOME}/.config/git/.gitconfig.local"
mkdir -p "${HOME}/.ssh"
touch "${HOME}/.ssh/config"

ln -nfs "${DOTFILES_ROOT}/.zsh" "$HOME"
ln -nfs "${DOTFILES_ROOT}/.scripts" "$HOME"

# VSCode
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
if [[ -d "$VSCODE_USER_DIR" ]]; then
  for i in ./.vscode/*; do
    cp "${DOTFILES_ROOT}/${i#./}" "$VSCODE_USER_DIR${i##./.vscode}"
  done
fi

# tmux
TPM_ROOT="${HOME}/.tmux/plugins/tpm"
[[ ! -e "$TPM_ROOT" ]] && git clone https://github.com/tmux-plugins/tpm "$TPM_ROOT"
mkdir -p "${HOME}/.tmux"
ln -nfs "${DOTFILES_ROOT}/.tmux/.tmux.dev.conf" "${HOME}/.tmux/.tmux.dev.conf"
