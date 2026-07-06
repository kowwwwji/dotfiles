#!/bin/sh
# Claude Code の PreToolUse(Bash) hook。
# 破壊的・不可逆・外向き（デプロイ/push）なコマンドを検知したら permissionDecision:"ask"
# を返し、settings.json の skipAutoPermissionPrompt を上書きして必ずユーザー確認を挟む
# （原則7: 全自動より軽い確認）。該当しなければ何も出さず通常フローに任せる。
# 使い方: settings.json の hooks.PreToolUse(matcher "Bash") から呼ぶ。

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0

# クォートで囲まれた引数値（コミットメッセージ等）を除去してから検査する。
# 破壊的コマンドはクォートに包まれない前提で、メッセージ内の "git push" 等の
# 語による誤検知を防ぐ（トレードオフ: `sh -c "rm -rf ..."` は検知しない）。
scrubbed=$(printf '%s' "$cmd" | sed -e "s/'[^']*'//g" -e 's/"[^"]*"//g')

# 最初にマッチしたパターンの理由を採用する。パターンは拡張正規表現（grep -E）。
reason=""
check() {
  [ -z "$reason" ] || return 0
  printf '%s' "$scrubbed" | grep -Eq "$1" && reason="$2"
  return 0
}

check 'rm[[:space:]]+(-[[:alnum:]]*[rf]|--(recursive|force))' 'rm による再帰/強制削除'
check 'git[[:space:]]+push'                                   'git push（リモートへの反映）'
check 'git[[:space:]]+reset[[:space:]]+--hard'                'git reset --hard（変更の破棄）'
check 'git[[:space:]]+clean[[:space:]]+-'                     'git clean（未追跡ファイルの削除）'
check 'git[[:space:]]+branch[[:space:]]+(-[[:alnum:]]*D|--delete[[:space:]]+--force)' 'git branch -D（マージ確認なしのブランチ削除）'
check 'git[[:space:]]+checkout[[:space:]]+(-[[:alnum:]]*f|--force)' 'git checkout --force（変更の破棄）'
check 'git[[:space:]]+restore'                                'git restore（作業ツリーの変更の破棄）'
check '(^|[[:space:];&|(])sudo[[:space:]]'                    'sudo（管理者権限での実行）'
check '(^|[[:space:];&|(])dd[[:space:]][^|;&]*of='            'dd（デバイス/ファイルへの直接書き込み）'
check '(^|[[:space:];&|(])mkfs'                               'mkfs（ファイルシステム作成＝既存データ消去）'
check 'diskutil[[:space:]]+([[:alnum:]]*[Ee]rase[[:alnum:]]*|partitionDisk|reformat)' 'diskutil によるディスク消去/再フォーマット'
check '(curl|wget)[^|;&]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|da)?sh([[:space:]]|;|&|$)' 'リモートスクリプトのパイプ実行（curl | sh）'
check 'ch(mod|own)[[:space:]]+(-[[:alnum:]]*R|--recursive)'   'chmod/chown -R（再帰的な権限変更）'
check '(tofu|terraform)[[:space:]]+(apply|destroy)'          'IaC の apply/destroy（インフラ変更）'
check 'kubectl[[:space:]]+(delete|apply)'                     'kubectl によるクラスタ変更'

if [ -n "$reason" ]; then
  # PreToolUse の ask 起因の許可プロンプトでは Notification イベントが発火せず
  # notify.sh が呼ばれないため、ここで直接通知する（原則4: awareness）。
  tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
  terminal-notifier -title "Claude Code: ${tmux_info}" -message "確認が必要: ${reason}" -sound default >/dev/null 2>&1
  jq -n --arg r "$reason" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: ("確認が必要: " + $r)}}'
fi
exit 0
