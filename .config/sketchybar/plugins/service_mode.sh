#!/bin/sh

# aerospace の service mode 表示を service アイテム（$NAME）へ反映する。
# aerospace_mode_change イベントで $MODE（service / main）が渡ってくる
# （aerospace 側は aerospace.toml の各 mode バインドが --trigger で発火する）。
# キー一覧の popup は sketchybarrc が起動時に組み立て済みなので、ここは
# 表示のトグルだけを行う。
# 設計: .claude/specs/2026-08-07-aerospace-service-mode-indicator-design.md

if [ "$MODE" = "service" ]; then
  sketchybar --set "$NAME" drawing=on popup.drawing=on
else
  sketchybar --set "$NAME" drawing=off popup.drawing=off
fi
