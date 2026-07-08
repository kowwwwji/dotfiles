#!/bin/sh
# 直近1分のロードアベレージをコア数で正規化し、%でステータスバーに表示する。
# .tmux.conf の status-right から #() で呼ばれる。
# Why: 生のロードアベレージはコア数と比べないと高低を判断できない。
#      「100% = 全コアが埋まる負荷」に正規化すれば一目で読める。
#      5分・15分平均は表示しない(常時視界にあるステータスバーではトレンドは
#      眺めていれば分かるため、1分平均だけで足りる)。
# 色は隣の sysstat (CPU/MEM) と同じ green/yellow/red の3段階に揃える。
# 依存は sysctl と awk のみ(macOS 標準)。

load=$(sysctl -n vm.loadavg | awk '{print $2}')
ncpu=$(sysctl -n hw.ncpu)

# 取得に失敗したら何も表示しない(ステータスバーを壊さない)
[ -n "$load" ] && [ -n "$ncpu" ] || exit 0

pct=$(awk -v l="$load" -v n="$ncpu" 'BEGIN { printf "%.0f", l / n * 100 }')

# 100% = 全コア飽和。70%からを警告域とする
if [ "$pct" -ge 100 ]; then
  color=red
elif [ "$pct" -ge 70 ]; then
  color=yellow
else
  color=green
fi

printf 'Load:#[fg=%s]%s%%#[default]' "$color" "$pct"
