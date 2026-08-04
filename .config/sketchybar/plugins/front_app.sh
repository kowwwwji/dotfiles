#!/bin/sh

# front_app_switched イベントの $INFO（前面アプリ名）をラベルへ、
# icon_map.sh のリガチャを icon へ反映する（icon.font は sketchybarrc 側で
# sketchybar-app-font を指定。未知アプリは :default: グリフに落ちる）
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$("$PLUGIN_DIR/icon_map.sh" "$INFO")
  sketchybar --set "$NAME" icon="${ICON% }" label="$INFO"
fi
