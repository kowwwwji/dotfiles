#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Music Folder Shuffle
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎧
# @raycast.packageName Music
# @raycast.argument1 { "type": "text", "placeholder": "フォルダ名（空なら Work）", "optional": true }

on run argv
	set q to "Work"
	if (count of argv) > 0 and item 1 of argv is not "" then set q to item 1 of argv

	tell application "Music"
		-- フォルダ名は部分一致（大文字小文字を区別しない）。"run" で Running を引けるように
		set folders to every folder playlist whose name contains q
		if folders is {} then return "「" & q & "」に一致するフォルダがありません"
		set theFolder to item 1 of folders
		set folderID to persistent ID of theFolder

		set cands to {}
		-- フォルダの中身は Apple Music から追加した subscription playlist で、
		-- every user playlist には含まれないため全プレイリストから親フォルダで絞る
		repeat with p in (every playlist)
			try
				if persistent ID of parent of p is folderID then set end of cands to contents of p
			end try
		end repeat

		if cands is {} then return name of theFolder & " フォルダにプレイリストがありません"

		set target to some item of cands
		set shuffle enabled to true
		play target
		return "▶ " & name of theFolder & " / " & name of target
	end tell
end run
