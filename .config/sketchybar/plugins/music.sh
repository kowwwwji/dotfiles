#!/bin/sh

# Apple Music の再生中トラックを表示する。
# music_change イベント（com.apple.Music.playerInfo distributed notification）と
# 起動時の sketchybar --update、ホバー（mouse.entered/exited）から呼ばれる。
# ポーリングはしない（sketchybarrc の設計方針）。
#
# バー上は曲名のみ短め表示（max_chars は sketchybarrc 側）。フル情報は popup の
# music.title / music.artist / music.album に music_change 時点で事前セットしておき、
# ホバーは popup.drawing のトグルだけにする（ホバーごとの osascript 遅延を避ける）。
#
# notification の $INFO（userInfo）は形式が sh で安定パースできないため使わない。
# イベントはトリガーとしてだけ使い、状態は毎回 osascript で取り直す（単一ソース）。
#
# NOTE: 初回実行時に macOS の Automation 許可（sketchybar → Music）ダイアログが出る。
# PC ごとに1回「許可」する。拒否すると osascript が失敗し、アイテムは非表示のままになる。

# ホバーは表示トグルのみで即 return（曲情報は事前セット済み）
case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" popup.drawing=on
    exit 0
    ;;
  mouse.exited)
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
esac

# is running ガードの外で tell application "Music" すると未起動の Music が
# 勝手に起動してしまうため、必ずガードの内側で問い合わせる。
# 出力は「state / 曲名 / アーティスト / アルバム」の4行。未起動・stopped・取得失敗は空。
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
        -- album はシングル・ラジオ等で欠けることがあるため個別 try で空を許容する
        set alb to ""
        try
          set alb to album of current track
        end try
        return pstate & linefeed & (get name of current track) & linefeed & (get artist of current track) & linefeed & alb
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
ALBUM=$(printf '%s\n' "$OUT" | sed -n '4p')

# 曲情報が取れないケース（未起動・stopped・TCC 拒否・current track なし）は
# アイテムごと非表示にして、バーに壊れた表示を残さない。popup も明示的に閉じて
# 「アイテムだけ消えて popup が開いたまま」を防ぐ
if [ -z "$TITLE" ]; then
  sketchybar --set "$NAME" drawing=off popup.drawing=off
  exit 0
fi

if [ "$STATE" = "playing" ]; then
  ICON="󰝚"
else
  ICON="󰏤"
fi

# アルバム名が空（シングル・ラジオ等）のときは行ごと隠す
if [ -n "$ALBUM" ]; then
  ALBUM_DRAWING=on
else
  ALBUM_DRAWING=off
fi

sketchybar --set "$NAME" drawing=on icon="$ICON" label="$TITLE" \
           --set music.title label="$TITLE" \
           --set music.artist label="$ARTIST" \
           --set music.album label="$ALBUM" drawing=$ALBUM_DRAWING
