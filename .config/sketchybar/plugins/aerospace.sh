#!/bin/sh

# aerospace の WS 状態を space.<N> アイテム（$NAME）へ反映する。$1 = 担当 WS 番号。
# 呼ばれ方は2通り:
# - aerospace_workspace_change イベント（$FOCUSED_WORKSPACE が渡ってくる。
#   on-focus-changed 経由では付かないため空なら aerospace へ問い合わせる）
# - sketchybar --update 等の強制実行（環境変数なし → 同上）
# 表示規則: 非空 or フォーカス中の WS のみ表示（設計: .claude/specs/2026-08-04-wm-additional-config-design.md）
# label にはその WS にいるアプリのアイコン列（sketchybar-app-font のリガチャ）を出す
# （設計: .claude/specs/2026-08-04-sketchybar-content-design.md）

WS="$1"
PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

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

if [ "$WS" != "$FOCUSED" ] && ! aerospace list-workspaces --empty no --monitor all 2>/dev/null | grep -qx "$WS"; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# 表示する WS のみアプリ一覧を引き、重複を除いてリガチャ列へ変換する。
# list-windows の出力順を保った初出順の重複除去にする（alt+tab の自作巡回
# focus-cycle.sh と同じ順序ソースにして、アイコン列と巡回順を一致させる）。
# アプリが無い（フォーカス中の空 WS）ときは label 自体を消して WS 番号だけにする
APPS=$(aerospace list-windows --workspace "$WS" --format '%{app-name}' 2>/dev/null | awk '!seen[$0]++')
if [ -n "$APPS" ]; then
  OLD_IFS=$IFS
  IFS='
'
  # 改行区切りのアプリ名を1語ずつ引数に展開する（クォート無しは意図的）
  set -- $APPS
  IFS=$OLD_IFS
  ICONS=$("$PLUGIN_DIR/icon_map.sh" "$@")
  ICONS=${ICONS% } # icon_map.sh はスペース区切りで末尾にも付けるため削る
  LABEL_DRAWING=on
else
  ICONS=""
  LABEL_DRAWING=off
fi

if [ "$WS" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" drawing=on \
             background.drawing=on background.color="$COLOR_INFO" \
             icon.color="$COLOR_INFO_CONTENT" label.color="$COLOR_INFO_CONTENT" \
             label="$ICONS" label.drawing="$LABEL_DRAWING"
else
  sketchybar --set "$NAME" drawing=on \
             background.drawing=off \
             icon.color="$COLOR_PRIMARY" label.color="$COLOR_PRIMARY" \
             label="$ICONS" label.drawing="$LABEL_DRAWING"
fi
