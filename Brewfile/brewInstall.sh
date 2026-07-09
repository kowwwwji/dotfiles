#!/bin/zsh
# 全PC共通(Brewfile.common) → machine固有(Brewfile.$DOTFILES_HOST) の順に brew bundle する。
# machineラベルは ~/.zsh/local.zsh の DOTFILES_HOST（git管理外）で決まる。

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

if [ -z "${DOTFILES_HOST:-}" ]; then
  echo "DOTFILES_HOST が未設定です。~/.zsh/local.zsh に 'export DOTFILES_HOST=work' 等を設定してください。" >&2
  exit 1
fi

brew bundle --file="$SCRIPT_DIR/Brewfile.common"
brew bundle --file="$SCRIPT_DIR/Brewfile.$DOTFILES_HOST"
