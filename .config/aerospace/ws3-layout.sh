#!/bin/sh

# WS3（縦置き PL2390）を既定配置に組み直す:
#   上段 = ミュージック（全幅）／ 下段 = リマインダー（左）｜カレンダー（右）
#
# aerospace のツリー構造は実行時状態で、窓の開き直しや再起動で崩れる。配置を設定で
# 宣言する手段が無いため、CLI で毎回同じ手順を踏んで組み直す。
#
# 手順の Why:
# - 入れ子の結合（join-with）は「直上の窓」を相手にするため、root 内の並び順が肝になる。
#   flatten 直後の並びは安定しないので、下段の窓を一度別 WS へ出して戻し、root 末尾へ
#   追加される性質で 上→下 の順を確定させる（退避先は名前付き WS。空になれば消える）。
# - 新しい入れ子コンテナは default-root-container-layout（accordion）を引くことがあり、
#   そのままだと右の窓が左の窓の裏に隠れるため、結合後に明示的に h_tiles へ切り替える。
# - 無い窓は読み飛ばす（ミュージックだけなら上下 tiles の root を揃えるだけで終わる）。

WS=3
TMP_WS="ws${WS}-rebuild"
TOP_APP='com.apple.Music'
BOTTOM_LEFT_APP='com.apple.reminders'
BOTTOM_RIGHT_APP='com.apple.iCal'

win_id() {
  aerospace list-windows --workspace "$WS" --app-bundle-id "$1" --format '%{window-id}' 2>/dev/null | head -1
}

# 「すでにその状態」でも exit 0 で告知が出るだけなので、告知は捨てる
quiet() { "$@" >/dev/null 2>&1; }

TOP=$(win_id "$TOP_APP")
BL=$(win_id "$BOTTOM_LEFT_APP")
BR=$(win_id "$BOTTOM_RIGHT_APP")

for id in $TOP $BL $BR; do
  quiet aerospace layout tiling --window-id "$id"
done

aerospace flatten-workspace-tree --workspace "$WS"

# 下段の窓を 左→右 の順で入れ直し、root の並びを 上, 左, 右 に固定する
for id in $BL $BR; do
  aerospace move-node-to-workspace --window-id "$id" "$TMP_WS" \
    && aerospace move-node-to-workspace --window-id "$id" "$WS"
done

quiet aerospace layout --workspace "$WS" --root v_tiles

# 右下を直上（左下）と同じコンテナにまとめ、左右 tiles にする
if [ -n "$BL" ] && [ -n "$BR" ]; then
  aerospace join-with --window-id "$BR" up
  quiet aerospace layout --window-id "$BR" h_tiles
fi
