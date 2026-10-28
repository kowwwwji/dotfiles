#!/bin/sh

# WS3（縦置き PL2390）を既定配置に組み直す:
#   上段 = 左 Notion カレンダー ／ 右 リマインダー / Bluesky の accordion
#   下段 = ミュージック / ジャーナル の accordion
#   （accordion は padding 0 なので 1 窓が全面。裏の窓へは alt-tab の巡回で移る）
#
# aerospace のツリー構造は実行時状態で、窓の開き直しや再起動で崩れる。配置を設定で
# 宣言する手段が無いため、CLI で毎回同じ手順を踏んで組み直す。
#
# 手順の Why:
# - flatten 直後の root 内の並びは安定しない。先頭以外の窓を上→下・左→右の順に一度
#   別 WS へ出して戻し、root 末尾へ追加される性質で並びを確定させる（退避先は
#   名前付き WS。空になれば消える）。
# - 束（`+` でつないだ窓）を先に組む。2 窓目を join-with で「直上の窓」（= 束の 1 窓目）と
#   まとめる。束の向きは入れ子の正規化（opposite-orientation）に任せ、段に入れた後で
#   向きなしの accordion を当てる（先に向きを指定しても段に入れた時点で反転されるため）。
# - 段の 2 要素目は join-with で 1 要素目と同じコンテナにまとめる。join-with は窓から
#   しか打てず、束の中の窓から打つと束から抜けてしまうため、単独窓の側から束へ向けて打つ。
#   新しい入れ子コンテナが引くレイアウトは状況で変わるため、結合後に段の指定
#   （h_tiles / h_accordion）を明示的に当てる。
# - 幅は px の絶対指定（resize width N）。WS3 は PL2390 固定運用なので比率でなく px で足りる。
#   指定した窓以外は残り幅を分け合う（accordion の段では意味を持たない）。
# - 無い窓は読み飛ばす（残っている窓だけで同じ順に積む）。

WS=3
TMP_WS="ws${WS}-rebuild"
# 1 行 = 1 段。上から順に、同じ段は左から順に要素を並べる（1 段 2 要素まで想定）。
# 行頭に `accordion` を置くとその段を accordion にする（省略時は左右 tiles）。
# 要素は bundle id。`a+b` と書くとその位置に a / b の accordion を置く（束は 2 窓まで、
# 1 段に束は 1 つまで）。`bundle-id:幅px` で幅を固定できる（省略時は残り幅を均等に分け合う）
ROWS='com.cron.electron com.apple.reminders+xyz.blueskyweb.app
accordion com.apple.Music com.apple.journal'

win_id() {
  aerospace list-windows --workspace "$WS" --app-bundle-id "$1" --format '%{window-id}' 2>/dev/null | head -1
}

# 「すでにその状態」でも exit 0 で告知が出るだけなので、告知は捨てる
quiet() { "$@" >/dev/null 2>&1; }

# 要素（id[:幅][+id[:幅]]）を空白区切りの window-id 列にする
ids_of() { printf '%s' "$1" | sed 's/:[0-9]*//g' | tr '+' ' '; }

# ROWS を「段のレイアウト 要素 ...（段ごとに改行区切り）」に解決する。要素は
# window-id[:幅] を + でつないだもの。開いていないアプリは落とす
ROW_IDS=$(printf '%s\n' "$ROWS" | while IFS= read -r row; do
  # NOTE: $( ) の中では case のパターン末尾 ')' が置換の閉じと誤解釈されるため if で判定する
  layout=h_tiles
  if [ "${row%% *}" = accordion ]; then
    layout=h_accordion
    row=${row#accordion }
  fi
  ids=''
  for entry in $row; do
    group=''
    for part in $(printf '%s' "$entry" | tr '+' ' '); do
      app=${part%%:*}
      width=${part#"$app"}
      id=$(win_id "$app")
      [ -n "$id" ] && group="${group:+$group+}$id$width"
    done
    [ -n "$group" ] && ids="$ids $group"
  done
  [ -n "$ids" ] && printf '%s%s\n' "$layout" "$ids"
done)

ALL_IDS=$(printf '%s\n' "$ROW_IDS" | sed 's/^[a-z_]* *//' | while IFS= read -r row; do ids_of "$row"; echo; done | tr '\n' ' ')
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

# 段ごとに束を組む → 段の 2 要素をまとめて段のレイアウトを当てる → 束に accordion を当てる
# （既定 IFS の read で先頭語を layout、残りを row に分ける）
printf '%s\n' "$ROW_IDS" | while read -r layout row; do
  for entry in $row; do
    set -- $(ids_of "$entry")
    [ $# -ge 2 ] && aerospace join-with --window-id "$2" up
  done

  set -- $row
  if [ $# -ge 2 ]; then
    a=$(ids_of "$1")
    b=$(ids_of "$2")
    anchor=''
    if [ "$b" = "${b% *}" ]; then
      aerospace join-with --window-id "$b" up && anchor=$b
    elif [ "$a" = "${a% *}" ]; then
      aerospace join-with --window-id "$a" down && anchor=$a
    else
      echo "ws3-layout: 束どうしは同じ段に置けない: $row" >&2
    fi
    [ -n "$anchor" ] && quiet aerospace layout --window-id "$anchor" "$layout"
  fi

  for entry in $row; do
    set -- $(ids_of "$entry")
    [ $# -ge 2 ] && quiet aerospace layout --window-id "$2" accordion
  done
done

# 幅指定があれば最後に当てる（段・束を組み終えてからでないと効く対象が定まらない）
for part in $(printf '%s\n' "$ROW_IDS" | sed 's/^[a-z_]* *//' | tr '+' ' '); do
  if [ "$part" != "${part#*:}" ]; then
    aerospace resize --window-id "${part%%:*}" width "${part#*:}"
  fi
done
