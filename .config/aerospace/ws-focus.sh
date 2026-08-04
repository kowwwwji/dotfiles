#!/bin/sh

# ワークスペース切替の着地を確認し、外れていたら切替し直す。$1 = 目的 workspace
#
# aerospace workspace N は、目的 WS の最前面が複数ウィンドウのアプリ（Chrome 等）だと
# macOS のアプリアクティベーションに「そのアプリが最後に使った窓」（別 WS のことも
# ある）へフォーカスを横取りされ、別の workspace に着地することがある
# （focus-cycle.sh が対処しているのと同じ挙動。1回目でアプリがアクティブ化済みに
# なるため、リトライは狙った WS に定着する）。
#
# 横取りは切替の少し後に非同期で起きるため、着地確認は一拍おいて2回行う。
# 連打（alt-2 → alt-3 など）で古い呼び出しが新しい切替を巻き戻さないよう、
# 最新の目的 WS を状態ファイルに書き、自分が最新でなくなったら身を引く。

TARGET="$1"
STATE="${TMPDIR:-/tmp}/aerospace-ws-focus-target"

printf '%s' "$TARGET" > "$STATE"

i=0
while [ "$i" -lt 3 ]; do
  if [ "$(aerospace list-workspaces --focused 2>/dev/null)" = "$TARGET" ]; then
    sleep 0.15 # 横取りは遅れて来るため、成功に見えても一拍おいて再確認する
    [ "$(aerospace list-workspaces --focused 2>/dev/null)" = "$TARGET" ] && exit 0
  fi
  [ "$(cat "$STATE" 2>/dev/null)" = "$TARGET" ] || exit 0 # より新しい切替に譲る
  aerospace workspace "$TARGET"
  sleep 0.1
  i=$((i + 1))
done
exit 1
