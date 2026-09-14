#!/bin/sh
# Claude Code の状態を tmux の pane 単位で記録する hook（原則4: awareness）。
# セッション一覧（.scripts/tmux-session-list）がこれを読み、待ち/実行中を一覧に出す。
# bell は「何か起きた」までしか表せず、待ちと完了を区別できないため、状態そのものを残す。
# 使い方: settings.json の hooks から `sh ~/.claude/hooks/pane-state.sh <状態>`。
#   状態: waiting（入力/承認待ち） / running（実行中） / idle（応答完了） / clear（削除）
# stdin は読まず jq も使わない（ツール呼び出しごとに走る PostToolUse でも軽く保つため）。

# tmux 外で起動した Claude セッションでは何もしない。
[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

# $TMUX = "<socket>,<server pid>,<session index>"。tmux サーバを再起動すると pane id が
# 振り直されるため、世代（server pid）ごとにディレクトリを分けて前世代の状態と混ぜない。
server_pid=${TMUX#*,}
server_pid=${server_pid%%,*}
dir="${TMPDIR:-/tmp}/claude-pane-state-${server_pid}"

# $TMUX_PANE は "%4" 形式の pane id そのもの。window 名変更や window 移動に自動追従する。
file="${dir}/${TMUX_PANE#%}"

if [ "$1" = "clear" ]; then
  rm -f "$file"
else
  mkdir -p "$dir" && printf '%s\n' "$1" > "$file"
fi

# hook が失敗しても Claude の動作を止めない。
exit 0
