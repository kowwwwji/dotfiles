#!/bin/sh

# WS3（縦置き PL2390）を既定配置に組み直す:
#   上段 = ミュージック / カレンダー の accordion ／ 下段 = リマインダー / ジャーナル の accordion
#   （accordion は padding 0 なので段ごとに 1 窓が全面。裏の窓へは alt-tab の巡回で移る）
#
# aerospace のツリー構造は実行時状態で、窓の開き直しや再起動で崩れる。配置を設定で
# 宣言する手段が無いため、CLI で毎回同じ手順を踏んで組み直す。
#
# 手順の Why:
# - flatten 直後の root 内の並びは安定しない。先頭以外の窓を上→下・左→右の順に一度
#   別 WS へ出して戻し、root 末尾へ追加される性質で並びを確定させる（退避先は
#   名前付き WS。空になれば消える）。
# - 同じ段の 2 窓目は join-with で「直上の窓」（= 同じ段の 1 窓目）と同じコンテナにまとめる。
#   新しい入れ子コンテナが引くレイアウトは状況で変わるため、結合後に段の指定
#   （h_tiles / h_accordion）を明示的に当てる。
# - 幅は px の絶対指定（resize width N）。WS3 は PL2390 固定運用なので比率でなく px で足りる。
#   指定した窓以外は残り幅を分け合う（accordion の段では意味を持たない）。
# - 無い窓は読み飛ばす（残っている窓だけで同じ順に積む）。

WS=3
TMP_WS="ws${WS}-rebuild"
# 1 行 = 1 段。上から順に、同じ段は左から順に bundle id を並べる（1 段 2 窓まで想定）。
# 行頭に `accordion` を置くとその段を accordion にする（省略時は左右 tiles）。
# `bundle-id:幅px` で幅を固定できる（省略時は残り幅を均等に分け合う）
ROWS='accordion com.apple.Music com.apple.iCal
accordion com.apple.reminders com.apple.journal'

win_id() {
  aerospace list-windows --workspace "$WS" --app-bundle-id "$1" --format '%{window-id}' 2>/dev/null | head -1
}

# 「すでにその状態」でも exit 0 で告知が出るだけなので、告知は捨てる
quiet() { "$@" >/dev/null 2>&1; }

# ROWS を「段のレイアウト window-id[:幅] ...（段ごとに改行区切り）」に解決する。
# 開いていないアプリは落とす
ROW_IDS=$(printf '%s\n' "$ROWS" | while IFS= read -r row; do
  # NOTE: $( ) の中では case のパターン末尾 ')' が置換の閉じと誤解釈されるため if で判定する
  layout=h_tiles
  if [ "${row%% *}" = accordion ]; then
    layout=h_accordion
    row=${row#accordion }
  fi
  ids=''
  for entry in $row; do
    app=${entry%%:*}
    width=${entry#"$app"}
    id=$(win_id "$app")
    [ -n "$id" ] && ids="$ids $id$width"
  done
  [ -n "$ids" ] && printf '%s%s\n' "$layout" "$ids"
done)

ALL_IDS=$(printf '%s\n' "$ROW_IDS" | sed 's/^[a-z_]* *//; s/:[0-9]*//g' | tr '\n' ' ')
[ -z "$(printf '%s' "$ALL_IDS" | tr -d ' ')" ] && exit 0

for id in $ALL_IDS; do
  quiet aerospace layout tiling --window-id "$id"
done

aerospace flatten-workspace-tree --workspace "$WS"

# 先頭（最上段の 1 窓目）はそのまま、残りを順に入れ直して並びを固定する
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

# 同じ段の 2 窓目以降を 1 窓目と結合して段のレイアウトを当て、幅指定があれば適用する
# （既定 IFS の read で先頭語を layout、残りを row に分ける）
printf '%s\n' "$ROW_IDS" | while read -r layout row; do
  first=1
  for entry in $row; do
    id=${entry%%:*}
    width=${entry#"$id"}
    width=${width#:}
    if [ "$first" = 1 ]; then
      first=0
    else
      aerospace join-with --window-id "$id" up
      quiet aerospace layout --window-id "$id" "$layout"
    fi
    [ -n "$width" ] && aerospace resize --window-id "$id" width "$width"
  done
done
