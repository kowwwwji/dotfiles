#!/bin/sh

# ワークスペース内のウィンドウを list-windows の出力順（アプリ名順）で巡回する。
# $1 = next | prev
#
# aerospace 標準の focus dfs-next/prev はツリー内部の DFS 順で巡回するが、その順序は
# CLI から取得できず、sketchybar の WS チップに並ぶアイコン列（list-windows 順）と
# 一致しない。巡回側を list-windows 順に置き換えることで、チップを見れば
# 「alt+tab でどの窓に移るか」が予測できるようにする（可視性重視）。
# 所要 ~30ms で体感差はない。

DIR="$1"

CUR=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
[ -z "$CUR" ] && exit 0

WINS=$(aerospace list-windows --workspace focused --format '%{window-id}' 2>/dev/null)
[ -z "$WINS" ] && exit 0

# prev は一覧を逆順にして「次」を探せば「前」になる
if [ "$DIR" = "prev" ]; then
  WINS=$(printf '%s\n' "$WINS" | tail -r)
fi

# CUR の次の行を返す。CUR が最終行（または一覧に無い）なら先頭へ wrap する
NEXT=$(printf '%s\n' "$WINS" | awk -v cur="$CUR" '
  NR==1 { first = $0 }
  prev == cur { print; found = 1; exit }
  { prev = $0 }
  END { if (!found) print first }
')

{ [ -z "$NEXT" ] || [ "$NEXT" = "$CUR" ]; } && exit 0

aerospace focus --window-id "$NEXT"

# Chrome など複数ウィンドウのアプリでは、非アクティブなアプリへの focus が
# 「そのアプリが最後に使った窓」（別 WS のこともある）に横取りされることがある
# （aerospace 標準の focus dfs-next でも発生する挙動）。結果を検証し、外れていたら
# 一度だけ focus し直す（1回目でアプリがアクティブ化済みのため2回目は狙った窓に入る）
if [ "$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)" != "$NEXT" ]; then
  aerospace focus --window-id "$NEXT"
fi
