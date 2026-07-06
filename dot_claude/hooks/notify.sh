#!/bin/sh
# Claude Code の Notification hook（承認待ち等で手が止まった時に発火）。
# tmux セッション名付きで macOS 通知に出し、裏 window で待たされていても気づけるようにする（原則4: awareness）。
# 使い方: settings.json の hooks.Notification から `sh ~/.claude/hooks/notify.sh` で呼ぶ。

input=$(cat)

# 入力待ちアイドル（idle_prompt: 応答完了から60秒後に発火）は Stop hook の
# 「終わったよ」通知と重複するため通知しない。notification_type は payload から
# 欠落することがある既知バグ（claude-code#11964）があるので message でも判定する。
type=$(printf '%s' "$input" | jq -r '.notification_type // empty')
message=$(printf '%s' "$input" | jq -r '.message // empty')
[ "$type" = "idle_prompt" ] && exit 0
case "$message" in *"waiting for your input"*) exit 0 ;; esac

# payload の message（例: "Claude needs your permission to use Bash"）を出し、
# 何の許可待ちかを通知だけで分かるようにする。
[ -n "$message" ] || message="コマンド実行していいですか"

tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message "$message" -sound Ping
