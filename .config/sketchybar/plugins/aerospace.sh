#!/bin/sh

# aerospace の WS 状態を space.<N> アイテム（$NAME）へ反映する。$1 = 担当 WS 番号。
# 呼ばれ方は2通り:
# - aerospace_workspace_change イベント（$FOCUSED_WORKSPACE が渡ってくる）
# - sketchybar --update 等の強制実行（環境変数なし → aerospace へ問い合わせる）
# 表示規則: 非空 or フォーカス中の WS のみ表示（設計: .claude/specs/2026-08-04-wm-additional-config-design.md）

WS="$1"

# tmux パレット準拠（sketchybarrc と同値）
COLOR_INFO=0xff00bafe         # @c-info #00BAFE
COLOR_INFO_CONTENT=0xff042e49 # @c-info-content #042E49
COLOR_PRIMARY=0xff5f5f87      # @c-primary #5f5f87

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# aerospace 未起動・失敗時は非表示にして正常終了（バーの他アイテムへ影響させない）
if [ -z "$FOCUSED" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$WS" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" drawing=on \
             background.drawing=on background.color="$COLOR_INFO" \
             icon.color="$COLOR_INFO_CONTENT"
elif aerospace list-workspaces --empty no --monitor all 2>/dev/null | grep -qx "$WS"; then
  sketchybar --set "$NAME" drawing=on \
             background.drawing=off icon.color="$COLOR_PRIMARY"
else
  sketchybar --set "$NAME" drawing=off
fi
