---
paths:
  - ".config/aerospace/**"
  - ".config/sketchybar/**"
---

# aerospace / sketchybar の規約と落とし穴

- **`mode` を切り替える行には `sketchybar --trigger aerospace_mode_change` を必ず添える。
  `[mode.service.binding]` は 1バインド = 1行を保つ**（tmux の which-key.yaml と同様、
  自動検出されないので手で揃える類のもの）。理由と挙動は aerospace.toml の同セクション
  直前のコメントが正。
- **設定の反映は service mode の `enter`**（aerospace の `reload-config` と `sketchybar --reload` を
  まとめて実行する）。sketchybar は設定ファイルを自動で読み直さないため、sketchybarrc や
  aerospace.toml のバインド（SERVICE popup の定義元）を変えたら必ずどちらかで再読み込みする。
