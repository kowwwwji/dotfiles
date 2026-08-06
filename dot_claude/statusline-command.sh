#!/bin/sh
# Claude Code の statusLine。ディレクトリと git はシェルプロンプト側に出るので、
# ここは Claude セッションの情報だけを出す: モデル・コンテキスト残量・コスト・使用量上限
# 表示例: Opus 4.8  ctx:73%  💰$0.42  5h:23% 7d:41%(F~33%)

input=$(cat)

# ── model ─────────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // .model.id // ""')

# ── context window (remaining %) ───────────────────────────────────────────────
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_str=""
[ -n "$remaining" ] && ctx_str="  ctx:${remaining%.*}%"

# ── cost ──────────────────────────────────────────────────────────────────────
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_str=""
if [ -n "$cost" ]; then
  cost_fmt=$(printf '%.2f' "$cost" 2>/dev/null)
  [ "$cost_fmt" != "0.00" ] && cost_str="  💰\$${cost_fmt}"
fi

# ── rate limits (Pro/Max only, after first API response) ───────────────────────
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── 週次のうち Fable が占める分（推定・(F~n%)） ────────────────────────────────
# 対象モデル・按分方式・その限界は model-share.sh を参照。ここの責務はキャッシュを
# 読んで整形するだけ。集計は 0.6 秒ほどかかるので毎レンダーでは待たず、古い値を出しつつ
# バックグラウンドで直す。取れないものが1つでもあれば黙って省略する
# （statusline 本体は絶対に壊さない）。
fable_str=""
resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
case "$resets_at" in ''|*[!0-9]*) resets_at="" ;; esac
if [ -n "$seven_d" ] && [ -n "$resets_at" ]; then
  cache="${HOME}/.claude/cache/model-share.json"
  # 集計期間は「直近7日」ではなく公式の週次ウィンドウに合わせる（resets_at の7日前が起点）
  since=$(( resets_at - 7 * 24 * 3600 ))
  # TTL 180秒。切れていたら再集計をキックするが、待たずに今回は古い値を出す
  if [ -z "$(find "$cache" -maxdepth 0 -mmin -3 2>/dev/null)" ]; then
    (sh "$(dirname "$0")/model-share.sh" "$since" >/dev/null 2>&1 </dev/null &)
  fi
  share=$(jq -r '.share // empty' "$cache" 2>/dev/null)
  case "$share" in ''|*[!0-9.]*) share="" ;; esac
  if [ -n "$share" ]; then
    fable=$(awk -v pct="$seven_d" -v s="$share" 'BEGIN { printf "%d", pct * s }')
    [ "$fable" -gt 0 ] 2>/dev/null && fable_str="(F~${fable}%)"
  fi
fi

rate_str=""
[ -n "$five_h" ]  && rate_str="${rate_str} 5h:${five_h%.*}%"
[ -n "$seven_d" ] && rate_str="${rate_str} 7d:${seven_d%.*}%${fable_str}"
[ -n "$rate_str" ] && rate_str="  ${rate_str# }"

printf '%s%s%s%s\n' "$model" "$ctx_str" "$cost_str" "$rate_str"
