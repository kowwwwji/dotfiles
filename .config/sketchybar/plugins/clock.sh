#!/bin/sh

# 日付・曜日つき時刻表示（例: 8/4(火) 17:45）。
# 曜日は locale に左右されない %u（ISO 曜日番号）→ 日本語1文字マップで自給自足。
# ゼロ埋め抑制の %-m は GNU 拡張で BSD date に無いため、パラメータ展開で先頭0を削る。

# スペース区切りの date 出力を1回の呼び出しで4変数に割る（クォート無しは意図的）
set -- $(date '+%m %d %u %H:%M')
MONTH=${1#0}
DAY=${2#0}
WDAY=$3
TIME=$4

case "$WDAY" in
  1) W=月 ;;
  2) W=火 ;;
  3) W=水 ;;
  4) W=木 ;;
  5) W=金 ;;
  6) W=土 ;;
  7) W=日 ;;
  *) W=? ;;
esac

sketchybar --set "$NAME" label="${MONTH}/${DAY}(${W}) ${TIME}"
