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
- **aerospace.toml のバインドを変えたら `sketchybar --reload`**。aerospace 側は service mode の
  `esc` で反映されるため、sketchybar だけ取り残されやすい。
