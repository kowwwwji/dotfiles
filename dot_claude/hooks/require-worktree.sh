#!/bin/sh
# Claude Code の PreToolUse(Edit|Write|NotebookEdit) hook。
# 自律編集モード（auto / bypassPermissions）でメインの作業ツリーを編集しようとしたら
# permissionDecision:"ask" で軽い確認を挟む（原則7: 全自動より軽い確認。
# 簡単な修正は都度許可し、まとまった作業は worktree へ誘導する）。
# worktree に存在し得ないファイル（リポジトリ外・gitignore 済み）は repo の diff に
# 現れず hook が守りたいものに該当しないため、無音で許可する。
# ask は permission-mode チェックより前に効くため bypass でも確認を回避できない。
# 使い方: settings.json の hooks.PreToolUse(matcher "Edit|Write|NotebookEdit") から呼ぶ。

input=$(cat)

# 自律編集モード以外（default / acceptEdits / plan）は通常フローに委ねる。
mode=$(printf '%s' "$input" | jq -r '.permission_mode // empty')
case "$mode" in
  auto | bypassPermissions) ;;
  *) exit 0 ;;
esac

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || exit 0

# git repo でなければ worktree 概念がないので通す。
gitdir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null) || exit 0
commondir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

# リンクされた worktree では git-dir(.../worktrees/<name>) と common-dir(.../.git) が
# 食い違う。食い違う＝正しく worktree 内 → 通す。一致＝メイン作業ツリー → 例外判定へ。
[ "$gitdir" != "$commondir" ] && exit 0

# 編集対象が worktree に存在し得ないファイルなら無音で許可する。
# ~/.claude/ 配下などの symlink 経由で repo 実体を編集するケースがあるため、
# 先に readlink -f で正規化する（失敗時＝新規ファイル等は元のパスのまま判定を続ける）。
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
if [ -n "$file" ]; then
  canonical=$(readlink -f "$file" 2>/dev/null) || canonical=$file
  toplevel=$(git -C "$cwd" rev-parse --show-toplevel)
  case "$canonical" in
    "$toplevel"/*)
      # リポジトリ内でも gitignore 済み（.claude/tasks/ 等）は無音で許可。
      git -C "$cwd" check-ignore -q -- "$canonical" && exit 0
      ;;
    *) exit 0 ;;
  esac
fi

# メインツリーの管理対象ファイル → 軽い確認。ask 起因の許可プロンプトでは
# Notification イベントが発火せず notify.sh が呼ばれないため、ここで直接通知する（原則4）。
tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
terminal-notifier -title "Claude Code: ${tmux_info}" -message "確認が必要: メイン作業ツリーの編集" -sound default >/dev/null 2>&1
jq -n --arg f "${file:-（パス不明）}" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: ("メイン作業ツリーの編集: " + $f + "。簡単な修正なら許可、まとまった作業なら worktree で（~/.claude/rules/worktree.md）")}}'
exit 0
