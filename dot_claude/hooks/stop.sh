#!/bin/sh
# Claude Code の Stop hook（応答が完了した時に発火）。
# macOS 通知に加え、pane の tty に bell を送って tmux の裏 window にも完了を可視化する（原則4: awareness）。
# 使い方: settings.json の hooks.Stop から `sh ~/.claude/hooks/stop.sh` で呼ぶ。

tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message '終わったよ' -sound default

# 発火元 pane の tty に bell(\a)を直接書き込む。裏 window でも monitor-bell フラグが立つ。
tty=$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
[ -n "$tty" ] && printf '\a' > "$tty"
