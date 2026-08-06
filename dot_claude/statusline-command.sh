#!/bin/sh
# Claude Code の statusLine。ディレクトリと git はシェルプロンプト側に出るので、
# ここは Claude セッションの情報だけを出す: モデル・コンテキスト残量・コスト・使用量上限
# 表示例: Opus 4.8  ctx:73%  💰$0.42  5h:23% 7d:41% Fable:100%

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

# ── モデル個別の週次上限（例: Fable:100%） ─────────────────────────────────────
# 5h/7d と違い statusline の JSON には来ないので、usage-limits.sh が API から取って
# 置いたキャッシュを読む。ここの責務は読んで整形するだけ。API を待たせないため、
# TTL 180秒を過ぎていたら取り直しをバックグラウンドでキックしつつ今回は古い値を出す。
# 取れなければ黙って省略する（statusline 本体は絶対に壊さない）。
# 7d と並列の別枠の上限なので、7d の内訳ではなく兄弟として並べる。
#
# サブスクセッション（= 5h/7d が来ている）でのみ扱う。API キー利用のセッションで
# 前回のサブスク由来のキャッシュを出すと嘘になるため、取得と表示に同じ門番をかける。
scoped_str=""
if [ -n "$seven_d" ]; then
  cache="${HOME}/.claude/cache/usage-limits.json"
  if [ -z "$(find "$cache" -maxdepth 0 -mmin -3 2>/dev/null)" ]; then
    (sh "$(dirname "$0")/usage-limits.sh" >/dev/null 2>&1 </dev/null &)
  fi
  # 上限に達しているものは赤くする（原則4: 見落とさない）。severity は API の判定をそのまま使う。
  scoped_str=$(jq -r '
    [ (.scoped // [])[]
      | select(.name != null and .percent != null)
      | (if .severity == "critical" then "\u001b[31m" else "" end)
        + .name + ":" + (.percent | floor | tostring) + "%"
        + (if .severity == "critical" then "\u001b[0m" else "" end) ]
    | join(" ")' "$cache" 2>/dev/null)
fi

rate_str=""
[ -n "$five_h" ]  && rate_str="${rate_str} 5h:${five_h%.*}%"
[ -n "$seven_d" ] && rate_str="${rate_str} 7d:${seven_d%.*}%"
[ -n "$scoped_str" ] && rate_str="${rate_str} ${scoped_str}"
[ -n "$rate_str" ] && rate_str="  ${rate_str# }"

printf '%s%s%s%s\n' "$model" "$ctx_str" "$cost_str" "$rate_str"
