#!/bin/sh
# Claude Code statusLine — Claude session info only (dir/git live in the shell prompt):
#   model · context-window · cost · rate-limits
# Example: Opus 4.8  ctx:73%  💰$0.42  5h:23% 7d:41%

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
rate_str=""
[ -n "$five_h" ]  && rate_str="${rate_str} 5h:${five_h%.*}%"
[ -n "$seven_d" ] && rate_str="${rate_str} 7d:${seven_d%.*}%"
[ -n "$rate_str" ] && rate_str="  ${rate_str# }"

printf '%s%s%s%s\n' "$model" "$ctx_str" "$cost_str" "$rate_str"
