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

# 質問・Plan承認では ask-notify.sh（PreToolUse）が質問文つきで通知済みのため、
# 直後に来る permission 通知（message にツール名が入らず文言では判別不能）を
# 重ねない。ask-notify.sh が残す印を一回きりで消費し、10秒以内なら黙る。
if [ "$type" = "permission_prompt" ] || [ -z "$type" ]; then
  session=$(printf '%s' "$input" | jq -r '.session_id // empty')
  marker="${TMPDIR:-/tmp}/claude-ask-notify-${session}"
  if [ -n "$session" ] && [ -f "$marker" ]; then
    marked_at=$(cat "$marker")
    rm -f "$marker"
    [ $(( $(date +%s) - marked_at )) -le 10 ] && exit 0
  fi
fi

# payload の message（例: "Claude needs your permission to use Bash"）を出し、
# 何の許可待ちかを通知だけで分かるようにする。
[ -n "$message" ] || message="コマンド実行していいですか"

tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message "$message" -sound Ping
