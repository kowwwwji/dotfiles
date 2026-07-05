#!/bin/sh
# Raycast Script Command: Karabiner-Elements の profile を次へ循環切替する。
# profile 名をハードコードせず一覧の次へ回すことで、2つならトグル、
# 3つ以上でも修正なしで循環する。切替結果は Raycast の HUD に表示される。
# 使い方: Raycast の Settings > Extensions > Script Commands にこのディレクトリを登録する。

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Karabiner Profile
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⌨️
# @raycast.packageName Karabiner

CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

if [ ! -x "$CLI" ]; then
  echo "karabiner_cli が見つかりません（Karabiner-Elements 未インストール？）"
  exit 1
fi

current=$("$CLI" --show-current-profile-name)
profiles=$("$CLI" --list-profile-names)

# 一覧を2回連結し、現在の profile の次の行を取る（末尾なら先頭へ折り返す）。
# 現在の profile が一覧に無ければ先頭の profile へフォールバックする。
next=$(printf '%s\n%s\n' "$profiles" "$profiles" \
  | awk -v cur="$current" 'found { print; exit } $0 == cur { found = 1 }')
[ -n "$next" ] || next=$(printf '%s\n' "$profiles" | head -n 1)

if [ -z "$next" ]; then
  echo "profile が見つかりません"
  exit 1
fi

"$CLI" --select-profile "$next"
echo "Karabiner: $next"
