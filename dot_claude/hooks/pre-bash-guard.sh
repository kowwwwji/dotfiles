#!/bin/sh
# Claude Code の PreToolUse(Bash) hook。
# 破壊的・不可逆・外向き（デプロイ/push）なコマンドを検知したら permissionDecision:"ask"
# を返し、settings.json の skipAutoPermissionPrompt を上書きして必ずユーザー確認を挟む
# （原則7: 全自動より軽い確認）。該当しなければ何も出さず通常フローに任せる。
# 使い方: settings.json の hooks.PreToolUse(matcher "Bash") から呼ぶ。

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0

# 最初にマッチしたパターンの理由を採用する。パターンは拡張正規表現（grep -E）。
reason=""
check() {
  [ -z "$reason" ] || return 0
  printf '%s' "$cmd" | grep -Eq "$1" && reason="$2"
  return 0
}

check 'rm[[:space:]]+(-[[:alnum:]]*[rf]|--(recursive|force))' 'rm による再帰/強制削除'
check 'git[[:space:]]+push'                                   'git push（リモートへの反映）'
check 'git[[:space:]]+reset[[:space:]]+--hard'                'git reset --hard（変更の破棄）'
check 'git[[:space:]]+clean[[:space:]]+-'                     'git clean（未追跡ファイルの削除）'
check '(tofu|terraform)[[:space:]]+(apply|destroy)'          'IaC の apply/destroy（インフラ変更）'
check 'kubectl[[:space:]]+(delete|apply)'                     'kubectl によるクラスタ変更'

if [ -n "$reason" ]; then
  jq -n --arg r "$reason" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: ("確認が必要: " + $r)}}'
fi
exit 0
