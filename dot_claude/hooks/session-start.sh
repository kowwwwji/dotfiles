#!/bin/sh
# Claude Code の SessionStart hook（startup/resume/clear/compact で発火）。
# プロジェクトの lessons ファイル（過去の修正から得た学び）を context に自動注入する。
# グローバル CLAUDE.md の「開始時に lessons をレビュー」を、お願いベースから機構的な
# 強制へ格上げする（自己改善ループの実装）。lessons が無ければ何も出さず素通り。
# 使い方: settings.json の hooks.SessionStart から `sh ~/.claude/hooks/session-start.sh`。

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || cwd=$PWD

# worktree で起動したセッションは gitignore 済みの .claude/ を持たないため、
# main worktree 側にもフォールバックする（--git-common-dir は worktree でも main の
# .git を指す）。main 自身や git 外では cwd と同じ場所を指すだけで無害。
main=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
main=${main%/.git}

# lessons の探索場所（commit されない .claude/tasks を優先、無ければ tasks/。
# cwd に無ければ main worktree 側を同順で探す）
for f in "$cwd/.claude/tasks/lessons.md" "$cwd/tasks/lessons.md" \
         "${main:+$main/.claude/tasks/lessons.md}" "${main:+$main/tasks/lessons.md}"; do
  [ -f "$f" ] || continue
  lessons=$(cat "$f")
  [ -n "$lessons" ] || continue
  # JSON 文字列エンコード（改行・引用符の処理）は jq に任せる。
  jq -n --arg ctx "このプロジェクトの過去の学び(lessons)。同じミスを繰り返さないこと:

$lessons" \
    '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
  exit 0
done
exit 0
