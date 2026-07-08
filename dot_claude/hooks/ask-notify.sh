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

# この直後に来る permission 通知を notify.sh が重ねないよう、印を残す
# （notify.sh が一回きりで消費する。詳細な判定は notify.sh 側）。
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -n "$session" ] && date +%s > "${TMPDIR:-/tmp}/claude-ask-notify-${session}"

tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message "$msg" -sound Ping >/dev/null 2>&1

# 発火元 pane の tty に bell(\a)を直接書き込む。裏 window でも monitor-bell フラグが立ち、
# 通知を見逃してもステータスバーの色で入力待ちに気づける。
tty=$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
[ -n "$tty" ] && printf '\a' > "$tty"
exit 0
