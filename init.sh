#!/bin/zsh

DOTFILES_ROOT=`ghq root`/github.com/kowwwwji/dotfiles

# TODO 一括でHOME配下に展開したい
for i in ./.* ; do
  [[ -f $i ]] \
    && ln -s ${DOTFILES_ROOT}/${i##./} ${HOME}/${i##./}
done;
ln -s ${DOTFILES_ROOT}/.config/nvim/plugins ${HOME}/.config/nvim/
ln -s ${DOTFILES_ROOT}/.config/nvim/UltiSnips ${HOME}/.config/nvim/
ln -s ${DOTFILES_ROOT}/.config/starship.toml ${HOME}/.config/starship.toml
ln -s ${DOTFILES_ROOT}/.config/coc-settings.json ${HOME}/.config/coc-settings.json

ln -s ${DOTFILES_ROOT}/.zsh $HOME
ln -s ${DOTFILES_ROOT}/.scripts $HOME

VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
if type "code" > /dev/null; then
  for i in ./.vscode/*; do
    cp ${DOTFILES_ROOT}/${i#./} "$VSCODE_USER_DIR${i##./.vscode}"
  done
fi

# Previmで使用するCSSの最新化
# TODO cssが変更されるとうまく行かない時がある
curl https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css | sed -e 's/.markdown-body //g' > ${DOTFILES_ROOT}/.template/github-markdown.css
