# worktree 作成の手順（gwq を使う）

> 本体（~/.claude/CLAUDE.md）からポインタで参照。worktree を切って作業するとき
> （require-worktree hook に編集を deny されたときを含む）に読む。

- **worktree の作成は `gwq add -b <branch>`**。素の `git worktree add` や
  EnterWorktree での新規作成（`name` 指定）は使わない。
- **Why**: gwq の規約パス外に作った worktree は `gwq get` / `gwq-window`（fzf →
  tmux window 切替）の一覧に載らず、ghq → gwq → tmux window の統合ワークフローと
  可視性から外れる。
- パスは `gwq get <branch>` で解決する。
- Claude Code セッションを worktree へ移すときは EnterWorktree を `path` 指定
  （`gwq get` の結果）で使う。Bash の `cd` はハーネスが元のディレクトリへ戻すため
  セッションの cwd は変わらない。元の場所へ戻るのは ExitWorktree の
  `action: "keep"`（`path` で入った worktree は remove 対象にならない）。
- ブランチ作成〜push〜draft PR までまとめて始めるときは `git-start -w <branch>`。
  push・PR 作成という外向き操作を含むため、ユーザーがそう指示したときだけ使う。
- 片付けは master 取り込み後に `gwq remove <branch>` と不要ブランチの削除。
