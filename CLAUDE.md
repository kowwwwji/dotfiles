# CLAUDE.md — このリポジトリで作業するAI向けガイド

kowwwwji の dotfiles / macOS セットアップリポジトリ。コードを見ても分かりにくい
このリポジトリ固有の設計思想・規約・落とし穴をまとめる。

> 全プロジェクト共通の作業方針は `dot_claude/CLAUDE.md`（= `~/.claude/CLAUDE.md`）側にある。
> こちらは「このリポジトリで作業するとき」専用。初回セットアップ手順は `README.md`。

## 設計思想（このリポジトリを貫く原則）

変更や追加を行うときは、まずこの原則に沿っているかを確認する。

1. **可搬性ファースト** — 複数のmacOS PCで長期運用する前提。ゴールは「どのPCでも
   `init.sh` を流せば同一環境になる」こと。新しい仕組みを足すときは最初に
   「全PCで再現するか」を問う。

2. **共有(base)とmachine固有(local)の層化分離** — リポジトリにはベースだけを置き、
   各PC固有・秘匿・仕事固有の設定は `local.*`（git管理外）へ逃がす。秘密や環境差は
   絶対にコミットしない（→「machine固有設定の分離」節）。

3. **自給自足・最小依存** — 既製バイナリ（gitmux, ccstatusline 等）を入れるより、
   `git` / `brew` / `jq` / POSIX sh で完結する自作を優先する。build ツールや linter を
   入れなくても動く状態を保つ。

4. **可視性・気づき(awareness)重視** — 複数PC・並行タスクで「どこで何が起きたか」を
   見落とさない設計。tmux の bell/silence フラグ、`terminal-notifier` 通知、通知のある
   window を優先表示する session 選択、statusline などが該当。機能追加時も
   「状態が見えるか」を意識する。

5. **Vim流操作の横断統一** — `hjkl` 移動・`Space` リーダー・`Ctrl+Space` prefix を
   nvim / tmux / zsh / lazygit / karabiner で揃える。新しいキーバインドは既存の語彙に合わせる。

6. **疎結合な統合ワークフロー** — ghq → worktree(gwq) → tmux window → lazygit → Claude が
   コンテキスト切替なしで連携する（例: `.scripts/git-start` は branch 作成から draft PR まで
   1コマンド）。各レイヤーは疎結合に保つ。

7. **自動化しすぎず判断を残す** — 破壊的操作は `confirm-before`、AI コミットは複数案を
   提案して選ばせる、監視は opt-in トグル。「全自動」より「軽い確認」を選ぶ。

8. **将来の自分向けの日本語ドキュメント** — コメント・説明は日本語。「何を」だけでなく
   「なぜ」を残す。読者は未来の自分。

## 前提環境

- **macOS** 専用（`terminal-notifier`・Homebrew・`Library/Application Support` 等に依存）。
- 配置先は複数PC。可搬性ファースト（原則1）を常に意識する。

## 配置の仕組み（最重要）

chezmoi ではなく `init.sh` の **手動 symlink** で `$HOME` に展開する。`dot_` プレフィックスは
chezmoi の自動変換ではなく、`dot_claude/` を明示的に `~/.claude/` へ貼っているだけ。

ファイルを追加・新規管理するときの判断：

1. **トップレベルのドットファイル**（例 `.zshrc` `.tmux.conf`）
   → `init.sh` 冒頭の `for i in ./.*` ループが自動で symlink する。**追記不要**。
2. **ディレクトリごと symlink 済みの配下**（`.config/nvim` `.zsh` `.scripts` など）
   → 親ディレクトリのリンクで自動的に入る。**追記不要**。
3. **個別ファイル単位でリンクしている配下**（`.tmux/` `dot_claude/` `.config/` の一部）
   → `init.sh` に `ln -nfs "${DOTFILES_ROOT}/path" "${HOME}/path"` を**明示的に追記する**。

> `.tmux/` はディレクトリ全体を symlink できない（TPM が `~/.tmux/plugins` を実体で使うため）。
> よって `.tmux/` 配下の新規スクリプトは必ず init.sh に1行足すこと。

> 例外: `dot_claude/settings.json` は **symlink しない**。Claude Code が `/model` 等の UI 操作を
> `~/.claude/settings.json` に書き込むため、直結するとリポジトリが汚れ続ける。
> `.scripts/claude-settings-sync` が「実体の上に base を重ねる」マージで配布する
> （base にあるキーは全PC共通で base が正、base に無いキーは実体側の値を保持）。
> **base を編集したら同スクリプトを再実行する**（他PCも pull 後に実行）。

> 例外: `.config/karabiner/karabiner.json` も **symlink しない**。Karabiner-Elements は
> 設定保存時（GUI 操作や `karabiner_cli --select-profile` を含む）にファイルを丸ごと
> 置き換えるため、symlink は保存のたびに切れる。`.scripts/karabiner-settings-sync` が
> リポジトリを正として配布する（`profiles[].selected` のみ実体側を保持）。
> **リポジトリ側を編集したら同スクリプトを再実行する**。GUI で足したルールは sync で
> 消えるので、残したいものは先にリポジトリの karabiner.json へ取り込む。

> 例外: user スコープの MCP サーバー定義も **symlink で配布できない**。置き場所が
> `~/.claude.json`（Claude Code が頻繁に書き込むホットな状態ファイル・git 管理外）のため、
> `.scripts/claude-mcp-sync` が公式 CLI（`claude mcp add-json`）経由で登録する
> （定義はスクリプト内が正）。**定義を編集したら同スクリプトを再実行する**（他PCも pull 後に実行）。
> どの経路の MCP をどこで管理するかは「MCP の管理」節。

> agent のスコープ: 汎用 agent は `dot_claude/agents/`（init.sh で `~/.claude/agents/` へ個別リンク）、
> このリポジトリ専用 agent は `.claude/agents/` に実体を置く（`.gitignore` の carve-out で追跡。リンク不要）。

> ignore の書き分け: `.gitignore` は**このリポジトリ専用**（$HOME には張らない）。全リポジトリ共通の
> パターンは `.gitignore_global`（init.sh が `~/.gitignore_global` へリンクし、core.excludesfile が参照）へ。

新ファイルを追加したら、**作業中のPCにも今すぐ symlink を張る**（init.sh は再実行しない限り
効かないため）。例: `ln -nfs "$PWD/.tmux/foo.sh" "$HOME/.tmux/foo.sh"`

## machine固有設定の分離（原則2の具体）

ベースはリポジトリ、machine固有・秘匿・仕事固有は以下の **git管理外ファイル** へ逃がす：

| 層 | ファイル | 用途 |
|----|---------|------|
| zsh | `~/.zsh/local.zsh` | 環境変数・トークン等（`local.zsh.sample` がテンプレ） |
| git | `~/.config/git/.gitconfig.local` | `.gitconfig` が `[include]` で読み込む。user名/メール等 |
| ssh | `~/.ssh/config` | 鍵・ホスト設定 |
| nvim | `~/.config/nvim/lua/config/local.lua` | PC固有のエディタ設定 |
| Claude | `~/.claude/settings.json` | git管理外の実体。Claude Code の自動書き込み（model 等）と machine固有・仕事固有の追記。base に無いキーは `claude-settings-sync` が保持する |

`dot_claude/settings.json` は共有 base（hooks・statusline・共通プラグイン・個人の好み）。仕事固有・
machine固有のものをここに書かない。なお `~/.claude/settings.local.json` は **Claude Code に読み込まれない**
（local settings はプロジェクトレベル `.claude/settings.local.json` のみ。ユーザーレベルは実測で不読を確認済み）。

## 補助スクリプトの方針（原則3の具体）

statusline や tmux の git 表示などは、**外部バイナリに依存しない POSIX sh スクリプト**で書く
（`dot_claude/statusline-command.sh` は jq のみ、`.tmux/git-status.sh` は git のみ）。`.scripts/` の
自作ツール（`git-start`, `gwq-window`, `tmux-session-select` 等）も同様。dotfiles だけで完結させ、
全PCで `init.sh` を流せば動く状態を保つ。

## MCP の管理

MCP サーバーは供給経路ごとに「正」を1箇所に固定する。**ローカルスコープ
（`claude mcp add` のデフォルト。`~/.claude.json` 内・git 管理外・可搬性なし）は使わない**。

| 経路 | 正（管理場所） | 反映方法 |
|------|--------------|---------|
| SaaS コネクタ（Gmail, Slack 等） | claude.ai Web | アカウント連携で自動 |
| プラグイン MCP | `dot_claude/settings.json` の enabledPlugins | `claude-settings-sync` |
| 独自 user スコープ MCP | `.scripts/claude-mcp-sync` 内の定義 | 同スクリプト実行 |
| プロジェクト固有 MCP | 各リポジトリの `.mcp.json` | リポジトリにコミット |

- **Why**: 定義が複数経路に散ると重複・drift する（実際に同一サーバーの三重定義・
  壊れた args が発生した）。追加・変更は必ず上表の「正」の場所で行い、他の経路に
  同名の定義を作らない。

## tmux

- ステータスバー配色は `@c-*` ユーザーオプション（`.tmux.conf` の Color palette 節）で定義。
- **Nerd Font アイコンは Material Design 系（コードポイント U+F0000 台）のみ使う**。
  FontAwesome 系（U+F04D など低い範囲）は使用フォントに無く豆腐になる。
  既存実績: `󱅫`(U+F116B) `󰂛`(U+F009B) `󰆍`(U+F018D)。
- 通知設計: `monitor-bell on` / `monitor-activity off`（p10k の再描画誤検知を避けるため）。
  bell/silence フラグで裏 window の状態を可視化（原則4）。
- 設定変更後の反映: `~/.tmux/reload.sh`（prefix は `Ctrl+Space`、リロード bind は `R`）。
  素の `source-file` はバインドの追加・上書きしかせず、config から削除・移動した
  バインドが幽霊として残る（デフォルトキーの復元もされない）ため、reload.sh が
  期待状態との差分を同期してから source する。
- **prefix キーバインドを追加・変更したら `.tmux/which-key.yaml` も必ず更新する**。
  tmux-which-key（prefix+Space のメニュー）はバインドを自動検出しない静的定義のため、
  更新しないとメニューと実際のバインドが乖離する。メニュー内キーは prefix バインドと
  同じキーに揃える（例: g=lazygit）。また `prefix+Space` はこのプラグインが後読みで
  上書きするため、他の用途にバインドできない。

> 注: 非ASCII（アイコン）を Edit ツールで挿入するとコードポイントが欠落して空白になることがある。
> 入った後に `[hex(ord(c)) for c in line if ord(c)>0x2000]` 等で実際に入ったか必ず検証する。

## 開発フロー（このリポジトリでの差分）

共通フロー（`dot_claude/rules/dev-flow.md`）との差分:

- **PR を作らない**。worktree ブランチへのコミットで引き渡し、ユーザーがローカルで
  merge する（master 直接コミット運用の延長）。
- **レビューは `dotfiles-reviewer`**（このリポジトリ固有の規約チェック）。
- **マージ後に反映作業がある**。settings / karabiner の sync スクリプト再実行や
  新規ファイルの symlink（→「配置の仕組み」節）。

## 規約

- **コミットメッセージ**: `type(scope) 日本語説明`。
  type は `add` / `fix` / `refactor` / `docs` / `update` / `delete`、
  scope は `tmux` `nvim` `claude` `git` など。master へ直接コミットする運用。
  （lazygit のカスタムコマンド `C` がこの形式を生成する。型の正は `.config/lazygit/config.yml`）
- 説明・コメントは日本語（原則8）。
