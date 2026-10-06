#!/bin/sh

# WS3（縦置き PL2390）を既定配置に組み直す:
#   上段 = ミュージック ／ 中段 = カレンダー ／ 下段 = リマインダー（すべて全幅の縦積み）
#
# aerospace のツリー構造は実行時状態で、窓の開き直しや再起動で崩れる。配置を設定で
# 宣言する手段が無いため、CLI で毎回同じ手順を踏んで組み直す。
#
# 手順の Why:
# - flatten 直後の root 内の並びは安定しない。2 段目以降の窓を上から順に一度別 WS へ
#   出して戻し、root 末尾へ追加される性質で並びを確定させる（退避先は名前付き WS。
#   空になれば消える）。
# - 無い窓は読み飛ばす（残っている窓だけで同じ順に積む）。

WS=3
TMP_WS="ws${WS}-rebuild"
# 上から順に並べるアプリ（bundle id）
APPS='com.apple.Music com.apple.iCal com.apple.reminders'

win_id() {
  aerospace list-windows --workspace "$WS" --app-bundle-id "$1" --format '%{window-id}' 2>/dev/null | head -1
}

# 「すでにその状態」でも exit 0 で告知が出るだけなので、告知は捨てる
quiet() { "$@" >/dev/null 2>&1; }

IDS=''
for app in $APPS; do
  id=$(win_id "$app")
  [ -n "$id" ] && IDS="$IDS $id"
done

for id in $IDS; do
  quiet aerospace layout tiling --window-id "$id"
done

aerospace flatten-workspace-tree --workspace "$WS"

# 先頭（最上段）はそのまま、2 段目以降を上から順に入れ直して並びを固定する
first=1
for id in $IDS; do
  if [ "$first" = 1 ]; then
    first=0
    continue
  fi
  aerospace move-node-to-workspace --window-id "$id" "$TMP_WS" \
    && aerospace move-node-to-workspace --window-id "$id" "$WS"
done

quiet aerospace layout --workspace "$WS" --root v_tiles
