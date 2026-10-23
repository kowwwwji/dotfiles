#!/bin/sh
# Raycast Script Command: Music.app の Genius シャッフルを開始する。
# Music の AppleScript 辞書に Genius シャッフルのコマンドは無いため、System Events で
# 「コントロール > Geniusシャッフル」メニュー項目をクリックする。アクセシビリティ API
# 経由なのでメニューバーを隠していても、Music が最前面でなくても効く。
# メニュー名は日英両方に一致させ、UI 言語が違う PC でも動くようにしている。
# 初回は Raycast にアクセシビリティ権限（システム設定 > プライバシーとセキュリティ）が必要。
# 使い方: Raycast の Settings > Extensions > Script Commands にこのディレクトリを登録する。

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Music Genius Shuffle
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎵
# @raycast.packageName Music

osascript <<'EOF'
-- 未起動なら起動する。running が true になってもメニューバーの構築はまだ先なので、
-- System Events 側でメニューバーが参照できるようになるまで待つ
tell application "Music"
  if not running then launch
end tell
tell application "System Events"
  repeat 20 times
    if exists menu bar 1 of process "Music" then exit repeat
    delay 0.5
  end repeat
end tell

tell application "System Events"
  tell process "Music"
    repeat with mi in menu bar items of menu bar 1
      set n to name of mi
      if n is "コントロール" or n is "Controls" then
        repeat with m in menu items of menu 1 of mi
          set mn to name of m
          if mn is "Geniusシャッフル" or mn is "Genius Shuffle" then
            -- disabled（Genius 未設定・ライブラリが空 等）だと click しても何も起きないので
            -- 成功と偽らず失敗として HUD に出す
            if not (enabled of m) then error "Genius シャッフルが無効です（Genius 未設定？）"
            click m
            return "Music: Genius Shuffle"
          end if
        end repeat
      end if
    end repeat
  end tell
end tell
error "Genius シャッフルのメニュー項目が見つかりません"
EOF
