#!/bin/sh

# WS3（縦置き PL2390）を既定配置に組み直す:
#   上段 = ミュージック ／ 中段 = カレンダー ／ 下段 = ジャーナル（左）｜リマインダー（右 420px）
#
# aerospace のツリー構造は実行時状態で、窓の開き直しや再起動で崩れる。配置を設定で
# 宣言する手段が無いため、CLI で毎回同じ手順を踏んで組み直す。
#
# 手順の Why:
# - flatten 直後の root 内の並びは安定しない。先頭以外の窓を上→下・左→右の順に一度
#   別 WS へ出して戻し、root 末尾へ追加される性質で並びを確定させる（退避先は
#   名前付き WS。空になれば消える）。
# - 同じ段の 2 窓目は join-with で「直上の窓」（= 同じ段の左隣）と同じコンテナにまとめる。
#   新しい入れ子コンテナは default-root-container-layout（accordion）を引くことがあり、
#   右の窓が左の窓の裏に隠れるため、結合後に明示的に h_tiles へ切り替える。
# - 幅は px の絶対指定（resize width N）。WS3 は PL2390 固定運用なので比率でなく px で足りる。
#   指定した窓以外は残り幅を分け合う。
# - 無い窓は読み飛ばす（残っている窓だけで同じ順に積む）。

WS=3
TMP_WS="ws${WS}-rebuild"
# 1 行 = 1 段。上から順に、同じ段は左から順に bundle id を並べる（1 段 2 窓まで想定）。
# `bundle-id:幅px` で幅を固定できる（省略時は残り幅を均等に分け合う）
ROWS='com.apple.Music
com.apple.iCal
com.apple.journal com.apple.reminders:420'

win_id() {
  aerospace list-windows --workspace "$WS" --app-bundle-id "$1" --format '%{window-id}' 2>/dev/null | head -1
}

# 「すでにその状態」でも exit 0 で告知が出るだけなので、告知は捨てる
quiet() { "$@" >/dev/null 2>&1; }

# ROWS を「window-id[:幅] 列（段ごとに改行区切り）」に解決する。開いていないアプリは落とす
ROW_IDS=$(printf '%s\n' "$ROWS" | while IFS= read -r row; do
  ids=''
  for entry in $row; do
    app=${entry%%:*}
    width=${entry#"$app"}
    id=$(win_id "$app")
    [ -n "$id" ] && ids="$ids $id$width"
  done
  [ -n "$ids" ] && printf '%s\n' "$ids"
done)

ALL_IDS=$(printf '%s\n' "$ROW_IDS" | tr '\n' ' ' | sed 's/:[0-9]*//g')
[ -z "$(printf '%s' "$ALL_IDS" | tr -d ' ')" ] && exit 0

for id in $ALL_IDS; do
  quiet aerospace layout tiling --window-id "$id"
done

aerospace flatten-workspace-tree --workspace "$WS"

# 先頭（最上段の左）はそのまま、残りを順に入れ直して並びを固定する
first=1
for id in $ALL_IDS; do
  if [ "$first" = 1 ]; then
    first=0
    continue
  fi
  aerospace move-node-to-workspace --window-id "$id" "$TMP_WS" \
    && aerospace move-node-to-workspace --window-id "$id" "$WS"
done

quiet aerospace layout --workspace "$WS" --root v_tiles

# 同じ段の 2 窓目以降を左隣と結合して左右 tiles にし、幅指定があれば適用する
printf '%s\n' "$ROW_IDS" | while IFS= read -r row; do
  first=1
  for entry in $row; do
    id=${entry%%:*}
    width=${entry#"$id"}
    width=${width#:}
    if [ "$first" = 1 ]; then
      first=0
    else
      aerospace join-with --window-id "$id" up
      quiet aerospace layout --window-id "$id" h_tiles
    fi
    [ -n "$width" ] && aerospace resize --window-id "$id" width "$width"
  done
done
