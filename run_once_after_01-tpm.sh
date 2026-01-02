#!/bin/bash

# Tmux Plugin Manager (TPM) のインストール
TPM_ROOT="${HOME}/.tmux/plugins/tpm"

if [ ! -e "$TPM_ROOT" ]; then
  echo "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_ROOT"
else
  echo "TPM is already installed"
fi
