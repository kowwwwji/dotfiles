#!/bin/sh
# Claude Code の Notification hook（承認待ち等で手が止まった時に発火）。
# tmux セッション名付きで macOS 通知に出し、裏 window で待たされていても気づけるようにする（原則4: awareness）。
# 使い方: settings.json の hooks.Notification から `sh ~/.claude/hooks/notify.sh` で呼ぶ。

tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message "コマンド実行していいですか" -sound default
