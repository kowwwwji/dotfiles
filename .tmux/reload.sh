#!/bin/sh
# tmux 設定のリロード + 幽霊バインドの掃除（prefix+R / which-key から run-shell で呼ぶ）
#
# source-file はバインドの追加・上書きしかしないため、config から削除・移動した
# バインドは稼働サーバに残り続ける（例: bind を C-g から c へ移すと旧 C-g が生きたまま。
# デフォルトキーを上書きしていた bind を消してもデフォルトには戻らない）。
# そこで「config が生成するはずのバインド一覧（デフォルト込み）」をスクラッチサーバで
# 作り、稼働サーバのバインドをそれへ同期してから source-file する:
#   - 稼働側にしか無い (table, key)      → unbind（幽霊の除去）
#   - スクラッチ側と定義が異なる/無い行  → スクラッチ側の bind-key 行を再適用
#     （デフォルトキーへ戻すケースを含む。list-keys の出力はそのまま実行できる形式）
#
# スクラッチ側の config からは tpm 行を除外する（continuum/resurrect の自動リストアが
# 見えないサーバ上で走るのを防ぐため）。このためプラグインが実行時に張るバインド
# （resurrect の C-s 等）も一旦同期で消えるが、直後の source-file で tpm が再実行され
# 再登録されるので最終状態は正しい。

set -eu

conf="${HOME}/.tmux.conf"
label="reload-check-$$"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"; TMUX= tmux -L "$label" kill-server 2>/dev/null || true' EXIT

# list-keys の出力（bind-key [-r] -T <table> <key> <command...>）から
# (table, key) をタブ区切りで取り出す
keys_of() { awk '{ if ($2 == "-r") print $4 "\t" $5; else print $3 "\t" $4 }'; }

grep -v 'plugins/tpm' "$conf" > "$tmp_dir/conf"
# セッションのコマンドは sleep（interactive shell を起動しない。script が
# 死んでも sleep 終了でサーバが自然消滅する保険を兼ねる）
TMUX= tmux -L "$label" -f "$tmp_dir/conf" new-session -d -s scratch 'sleep 30'
TMUX= tmux -L "$label" list-keys | sort > "$tmp_dir/expected"
TMUX= tmux -L "$label" kill-server

tmux list-keys | sort > "$tmp_dir/live"

# 同期コマンドを組み立てる。key は list-keys がエスケープ済みなので、
# シェルを介さず source-file で実行する（クォート事故を避ける）
{
  # 稼働側にしか無い行 → (table, key) を unbind
  grep -Fxvf "$tmp_dir/expected" "$tmp_dir/live" \
    | keys_of | awk -F '\t' '{ print "unbind-key -T " $1 " " $2 }'
  # スクラッチ側にしか無い行 → そのまま bind-key として再適用
  grep -Fxvf "$tmp_dir/live" "$tmp_dir/expected"
} > "$tmp_dir/sync" || true

if [ -s "$tmp_dir/sync" ]; then
  tmux source-file "$tmp_dir/sync"
fi
tmux source-file "$conf"
tmux display-message "Reloaded ~/.tmux.conf (stale binds cleaned)"
