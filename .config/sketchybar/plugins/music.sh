#!/bin/sh

# Apple Music の再生中トラックを表示する。
# music_change イベント（com.apple.Music.playerInfo distributed notification）と
# 起動時の sketchybar --update から呼ばれる。ポーリングはしない（sketchybarrc の設計方針）。
#
# notification の $INFO（userInfo）は形式が sh で安定パースできないため使わない。
# イベントはトリガーとしてだけ使い、状態は毎回 osascript で取り直す（単一ソース）。
#
# NOTE: 初回実行時に macOS の Automation 許可（sketchybar → Music）ダイアログが出る。
# PC ごとに1回「許可」する。拒否すると osascript が失敗し、アイテムは非表示のままになる。

# is running ガードの外で tell application "Music" すると未起動の Music が
# 勝手に起動してしまうため、必ずガードの内側で問い合わせる。
# 出力は「state / 曲名 / アーティスト」の3行。未起動・stopped・取得失敗は空。
OUT=$(osascript <<'EOF' 2>/dev/null
if application "Music" is running then
  tell application "Music"
    -- 変数名 st は AppleScript の予約語（1st 等の序数接尾辞）のため使えない
    set pstate to ""
    if player state is playing then
      set pstate to "playing"
    else if player state is paused then
      set pstate to "paused"
    end if
    if pstate is not "" then
      try
        return pstate & linefeed & (get name of current track) & linefeed & (get artist of current track)
      end try
    end if
  end tell
end if
return ""
EOF
)

STATE=$(printf '%s\n' "$OUT" | sed -n '1p')
TITLE=$(printf '%s\n' "$OUT" | sed -n '2p')
ARTIST=$(printf '%s\n' "$OUT" | sed -n '3p')

# 曲情報が取れないケース（未起動・stopped・TCC 拒否・current track なし）は
# アイテムごと非表示にして、バーに壊れた表示を残さない
if [ -z "$TITLE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$STATE" = "playing" ]; then
  ICON="󰝚"
else
  ICON="󰏤"
fi

LABEL="$TITLE"
[ -n "$ARTIST" ] && LABEL="$TITLE - $ARTIST"

sketchybar --set "$NAME" drawing=on icon="$ICON" label="$LABEL"
