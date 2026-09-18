---
paths:
  - ".tmux/**"
  - ".tmux.conf"
---

# tmux の規約と落とし穴

- ステータスバー配色は `@c-*` ユーザーオプション（`.tmux.conf` の Color palette 節）で定義。
- **Nerd Font アイコンは Material Design 系（コードポイント U+F0000 台）のみ使う**。
  FontAwesome 系（U+F04D など低い範囲）は使用フォントに無く豆腐になる。
  既存実績: `󱅫`(U+F116B) `󰂛`(U+F009B) `󰆍`(U+F018D)。
- 通知設計: `monitor-bell on` / `monitor-activity off`（p10k の再描画誤検知を避けるため）。
  bell/silence フラグで裏 window の状態を可視化（設計思想の原則4）。
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
