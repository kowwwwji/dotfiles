#!/bin/sh

# IME インジケータ: 日本語入力なら「あ」を @c-info で強調、英字なら「A」を通常色。
# 「今どちらで打つか」の気づき重視（設計: .claude/specs/2026-08-04-sketchybar-content-design.md）。
# 強調色はフォーカス中 WS チップの背景と同じ @c-info（アクティブ状態の色を揃える）。
# 入力ソース変更のイベントは存在しないためポーリング（update_freq=1）。
# 判定に失敗したら drawing=off でバーを壊さない。

# tmux パレット準拠（sketchybarrc と同値）
COLOR_FG=0xffc0c0c0   # @c-fg #c0c0c0
COLOR_INFO=0xff00bafe # @c-info #00BAFE

SRC=$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null)

if [ -z "$SRC" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# 日本語 IME はベンダー問わず Input Mode に com.apple.inputmethod.Japanese* を使う
# （Google 日本語入力・Kotoeri とも。英字モードは com.apple.inputmethod.Roman、
# IME なしのキーボードレイアウトは Input Mode 行自体が無い → どちらも「A」側）
case "$SRC" in
  *com.apple.inputmethod.Japanese*)
    sketchybar --set "$NAME" drawing=on label="あ" label.color="$COLOR_INFO"
    ;;
  *)
    sketchybar --set "$NAME" drawing=on label="A" label.color="$COLOR_FG"
    ;;
esac
