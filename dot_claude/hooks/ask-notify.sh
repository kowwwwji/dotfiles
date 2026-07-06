#!/bin/sh
# Claude Code の PreToolUse(AskUserQuestion|ExitPlanMode) hook。
# ターン途中の入力待ち（選択式の質問・Plan 承認）は Stop hook が発火せず、
# アイドル通知も notify.sh が捨てるため、UI が出る瞬間にここで直接通知する
# （原則4: awareness。裏 window で質問を出されたまま気づけない穴を塞ぐ）。
# 使い方: settings.json の hooks.PreToolUse(matcher "AskUserQuestion|ExitPlanMode") から呼ぶ。

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

case "$tool" in
  AskUserQuestion)
    msg=$(printf '%s' "$input" | jq -r '.tool_input.questions[0].question // empty')
    [ -n "$msg" ] || msg="質問があります"
    ;;
  ExitPlanMode) msg="Plan の承認待ち" ;;
  *) msg="入力待ち" ;;
esac

tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message "$msg" -sound Ping >/dev/null 2>&1
exit 0
