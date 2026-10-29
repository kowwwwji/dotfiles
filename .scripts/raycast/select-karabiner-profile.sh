#!/bin/sh
# Raycast Script Command: Karabiner-Elements の profile を名前指定で切り替える。
# 循環切替（toggle-karabiner-profile.sh）と違い、目的の profile へ一発で行ける。
# 引数は大文字小文字を区別せず一覧と照合する（hhkb → HHKB）ので、Raycast で打ちやすい。
# profile 間で virtual_hid_keyboard の keyboard_type（ansi / jis）が異なり、これは
# Karabiner を再起動しないと反映されないため、切替後にユーザー権限の Karabiner プロセスを
# 落とす（launchd が自動で再起動する）。root 権限のプロセスには届かないが、それで足りる。
# 使い方: Raycast の Settings > Extensions > Script Commands にこのディレクトリを登録する。

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Select Karabiner Profile
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⌨️
# @raycast.packageName Karabiner
# @raycast.argument1 { "type": "text", "placeholder": "profile (HHKB / JIS)" }

CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

if [ ! -x "$CLI" ]; then
  echo "karabiner_cli が見つかりません（Karabiner-Elements 未インストール？）"
  exit 1
fi

want=$1
if [ -z "$want" ]; then
  echo "profile 名を指定してください: $("$CLI" --list-profile-names | tr '\n' ' ')"
  exit 1
fi

# 大文字小文字を無視して一覧と照合し、正式な profile 名を得る。
profile=$("$CLI" --list-profile-names \
  | awk -v want="$want" 'tolower($0) == tolower(want) { print; exit }')

if [ -z "$profile" ]; then
  echo "profile '$want' がありません: $("$CLI" --list-profile-names | tr '\n' ' ')"
  exit 1
fi

"$CLI" --select-profile "$profile"

# プロセス名で照合する（-f でコマンドライン全体を見ると、パスに karabiner を含む
# このスクリプト自身を殺してしまう）。-u で自分のプロセスに絞り、root 所有分への
# Operation not permitted を出さない。
pkill -9 -i -u "$(id -u)" karabiner

echo "Karabiner: $profile"
