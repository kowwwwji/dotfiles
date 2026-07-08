# 開発フロー（worktree→実装→検証→レビュー→コミット→引き渡し→片付け）

> 本体（~/.claude/CLAUDE.md）からポインタで参照。実装タスク（コード変更を伴う作業）を
> 進めるときに読む。ここで定めるのはフローの順序と使い分けのみ。各ステップの詳細は
> 正本（worktree.md、CLAUDE.md の Git / PR 節）を参照する。

## 0. 規模判定

小さい修正（目安: 単一ファイル・数行、レビュー不要レベル）はメインツリーで直接行う
（require-worktree hook に確認されたら ask に応じる）。それ以外は worktree を切る。

## 1. worktree 作成

`gwq add -b type/短い説明`。命名・パス解決の詳細は worktree.md。

## 2. tmux 別 window の新セッションへ委譲

worktree を切ったら、同一セッションで作業を続けず、tmux の別 window で新しい
claude セッションを起動して作業を任せる:

1. `tmux new-window -d -n <ブランチ名> -c <worktreeパス>`（`-d` でフォーカスを奪わない）
2. その window で claude を起動し、スペック・計画の絶対パスを初期プロンプトで渡す
3. メインセッションは起動確認と報告まで

**Why**: メインの会話と window をユーザーの手元に残したまま実装を並行・可視化できる。
進捗は bell / 通知で把握できる。

## 3. 実装

スペック・計画に従う。

## 4. 検証

動作を証明できるまで完了としない（テスト実行・ログ確認・差分確認）。

## 5. レビュー

コミット前に、その repo 専用の reviewer agent（例: dotfiles の dotfiles-reviewer）が
あればそれを、なければ汎用 code-reviewer を呼ぶ。

## 6. コミット

- 直前に `git status --porcelain` と `git diff` で意図した変更だけかを確認する。
  **Why**: ユーザーが並行して git 操作をしていることがあり、会話内の記憶と repo の
  実状態はズレうる。
- `git add -A` を使わず対象ファイルを明示する。
- amend せず、作業単位で新規コミットを積む。
- メッセージは各 repo のコミット規約に従う。

## 7. 引き渡し

コミットで停止し、ブランチ名と worktree パスを報告する。マージはユーザーレビュー後
（CLAUDE.md の Git / PR 節が正）。draft PR はユーザー指示時のみ（git-start）。

## 8. マージと片付け

ユーザーの「レビューOK / マージして」の指示を受けたら Claude がまとめて行う:
セッション開始ブランチへのマージ → リポジトリ固有の反映作業（あれば）→
worktree・ブランチの削除（コマンドは worktree.md）→ 委譲先 tmux window のクローズ。
指示があるまでは何もしない。

- **window のクローズまでが片付け**。window は worktree とセットで作られる（手順2）ため、
  worktree 削除後に window だけ残るとノイズになる。
- 委譲先セッション自身が片付けを行う場合、閉じると window 内の claude セッションも
  終了するため、最終報告を出してから遅延バックグラウンドで自分の window を閉じる
  （例: `(sleep 3 && tmux kill-window -t <session>:<window>) &`）。
