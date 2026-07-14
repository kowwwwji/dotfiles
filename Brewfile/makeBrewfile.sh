#!/bin/zsh
# このPCに入っているパッケージから共通分(Brewfile.common)を差し引き、
# machine固有ファイル(Brewfile.$DOTFILES_HOST)を再生成する。
# machineラベルは ~/.zsh/local.zsh の DOTFILES_HOST（git管理外）で決まる。

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
COMMON="$SCRIPT_DIR/Brewfile.common"

if [ -z "${DOTFILES_HOST:-}" ]; then
  echo "DOTFILES_HOST が未設定です。~/.zsh/local.zsh に 'export DOTFILES_HOST=work' 等を設定してください。" >&2
  exit 1
fi

HOST_FILE="$SCRIPT_DIR/Brewfile.$DOTFILES_HOST"

# brew bundle dump は「入っているもの全部」をフラットに出す（共通/固有の区別なし）。
# dump 全体から common を差し引いた集合差が、このPC固有のパッケージ。
# --no-describe: brew は説明コメント行を各行に付けるのが既定。common はコメント無しの
# フラット形式なので、付けると comm の集合差でコメント行が相殺されず残る。無効化する。
TMP=$(mktemp)
COMMON_SORTED=$(mktemp)
trap 'rm -f "$TMP" "$COMMON_SORTED"' EXIT
brew bundle dump --file="$TMP" --force --no-describe

# comm は sorted 前提。プロセス置換 <() は zsh 専用で `sh makeBrewfile.sh` と起動すると
# 構文エラーになるため、一時ファイルへソートしてから渡す（POSIX sh でも動く）。
# 出力は逆順ソート（tap 行を先頭に）。
sort "$TMP" -o "$TMP"
sort "$COMMON" > "$COMMON_SORTED"
# dump が実体のないエントリを拾うため除外する:
# - npm "corepack": Node 同梱の corepack が npm list -g に出るだけで、明示インストールではない
# - go "cmd/...": mise 環境では GOBIN が go ツールチェーン自身の bin を指すため、
#   go/gofmt 本体を「go install されたパッケージ」と誤検出する
comm -23 "$TMP" "$COMMON_SORTED" | grep -vE '^(npm "corepack"|go "cmd/)' | sort -r > "$HOST_FILE"

echo "生成: $HOST_FILE ($(wc -l < "$HOST_FILE") 行)"
