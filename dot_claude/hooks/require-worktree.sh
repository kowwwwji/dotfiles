#!/bin/sh
# Claude Code の PreToolUse(Edit|Write|NotebookEdit) hook。
# auto mode(bypassPermissions) でメインの作業ツリーにいるときは編集を deny し、
# git worktree の中でしか自律編集できないよう矯正する
# （原則7: 全自動より軽い確認。auto mode の影響範囲を worktree に閉じ込める）。
# deny は permission-mode チェックより前に効くため bypass でも回避できない。
# 使い方: settings.json の hooks.PreToolUse(matcher "Edit|Write|NotebookEdit") から呼ぶ。

input=$(cat)

# auto mode 以外は通常フローに委ねる。
mode=$(printf '%s' "$input" | jq -r '.permission_mode // empty')
[ "$mode" = "bypassPermissions" ] || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || exit 0

# git repo でなければ worktree 概念がないので通す。
gitdir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null) || exit 0
commondir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

# リンクされた worktree では git-dir(.../worktrees/<name>) と common-dir(.../.git) が食い違う。
# 食い違う＝正しく worktree 内 → 通す。一致＝メイン作業ツリー → deny。
[ "$gitdir" != "$commondir" ] && exit 0

jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "auto mode(bypassPermissions) ではメインの作業ツリーを編集しない。git-start / gwq-window で worktree を作り、その中で起動して作業してください。"}}'
