#!/bin/bash
set -e

# ステージされた変更を取得
DIFF=$(git diff --staged)

if [ -z "$DIFF" ]; then
  echo "No staged changes to commit."
  read -p "Press Enter to continue..."
  exit 1
fi

# Claudeにコミットメッセージの提案を依頼
echo "Generating commit message suggestions with Claude..."
echo ""

# 一時ファイルを作成
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Claudeコマンドでメッセージを生成
claude --print "Based on the following git diff, suggest exactly 3 different commit messages in the format: type(scope) message

Use these types: add, fix, refactor, docs, update, delete

IMPORTANT: Output ONLY the 3 commit messages, one per line, with NO explanations, NO numbering, NO markdown, NO extra text.

Git diff:
$DIFF" > "$TEMP_FILE" 2>&1

# 結果を確認
if [ ! -s "$TEMP_FILE" ]; then
  echo "Error: Claude did not generate any suggestions."
  echo "Please check if 'claude' command is available."
  read -p "Press Enter to continue..."
  exit 1
fi

# 最後の3行を取得（Claudeの出力から実際のメッセージ部分のみ）
SUGGESTIONS=$(tail -n 3 "$TEMP_FILE")

# デバッグ用に出力を表示
# echo "Generated suggestions:"
# echo "$SUGGESTIONS"
# echo ""

# 提案を配列に格納
IFS=$'\n' read -rd '' -a MESSAGES <<< "$SUGGESTIONS" || true

# メニューを表示
echo ""
echo "Select a commit message:"
echo ""
for i in "${!MESSAGES[@]}"; do
  echo "$((i+1)). ${MESSAGES[$i]}"
done
echo "$((${#MESSAGES[@]}+1)). Edit custom message"
echo "$((${#MESSAGES[@]}+2)). Cancel"
echo ""

read -p "Enter your choice (1-$((${#MESSAGES[@]}+2))): " CHOICE

if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#MESSAGES[@]}" ]; then
  SELECTED="${MESSAGES[$((CHOICE-1))]}"
  git commit -m "$SELECTED"
  echo ""
  echo "Committed with message: $SELECTED"
elif [ "$CHOICE" -eq "$((${#MESSAGES[@]}+1))" ]; then
  read -p "Enter your custom message: " CUSTOM_MSG
  git commit -m "$CUSTOM_MSG"
  echo ""
  echo "Committed with message: $CUSTOM_MSG"
else
  echo "Commit cancelled."
fi
