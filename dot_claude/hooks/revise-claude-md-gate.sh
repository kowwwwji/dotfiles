#!/bin/sh
# Claude Code の Stop hook（メインセッションの応答完了時に発火。subagent では発火しない）。
# ファイル編集や git commit を行ったセッションで、まだ /revise-claude-md を実行していなければ
# 応答の終了を 1 回だけ止め、学びを CLAUDE.md に反映させる（自己改善ループの機構化）。
# 「1 回だけ」はセッション ID ごとのマーカーで担保する。質問だけのセッションでは何もしない。
# 使い方: settings.json の hooks.Stop から `sh ~/.claude/hooks/revise-claude-md-gate.sh`。

input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // empty')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
[ -n "$sid" ] && [ -f "$transcript" ] || exit 0

state_dir="$HOME/.claude/state/revise-claude-md-gate"
mkdir -p "$state_dir"
marker="$state_dir/$sid"
# 古いマーカーは掃除（セッションは残らないので 7 日で十分）
find "$state_dir" -type f -mtime +7 -delete 2>/dev/null

[ -f "$marker" ] && exit 0
# 既に Stop hook の block から継続中なら二重に止めない（ループ防止）
[ "$active" = "true" ] && exit 0

# 既に実行済み（Skill 呼び出し、またはユーザーのスラッシュコマンド）なら以後は止めない
if grep -qE '"skill":"(claude-md-management:)?revise-claude-md"|<command-name>/revise-claude-md</command-name>' "$transcript"; then
  touch "$marker"
  exit 0
fi

# 作業の痕跡: Edit/Write 系ツール、または Bash 経由の git commit
if ! grep -qE '"name":"(Edit|Write|NotebookEdit)"|git commit' "$transcript"; then
  exit 0
fi

touch "$marker"
jq -n '{
  decision: "block",
  reason: "このセッションではファイル編集やコミットを行っている。応答を終える前に、Skill ツールで claude-md-management:revise-claude-md を 1 回実行し、このセッションで得た学び（使ったコマンド、環境のクセ、ハマりどころ）を CLAUDE.md に反映する提案をユーザーに示すこと。提案を出したら、元の応答を完了してよい。"
}'
exit 0
