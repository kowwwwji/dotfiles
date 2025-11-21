#!/bin/bash

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/.mcp.json"
FORCE_OVERWRITE="${FORCE_OVERWRITE:-false}"

# ヘルプメッセージ
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -f, --force    Force overwrite existing MCP servers"
  echo "  -h, --help     Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                      # Skip existing servers"
  echo "  $0 --force              # Overwrite existing servers"
  exit 0
fi

# コマンドライン引数を処理
if [[ "$1" == "-f" || "$1" == "--force" ]]; then
  FORCE_OVERWRITE=true
fi

# 必要なコマンドの確認
for cmd in jq op claude; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required but not installed"
    exit 1
  fi
done

# 1Password にサインインしているか確認
if ! op account list &>/dev/null; then
  echo "Please sign in to 1Password CLI first:"
  echo "  eval \$(op signin)"
  exit 1
fi

# .mcp.jsonの存在確認
if [ ! -f "$MCP_CONFIG" ]; then
  echo "Error: $MCP_CONFIG not found"
  exit 1
fi

echo "🔐 Fetching credentials from 1Password and adding MCP servers..."
if [ "$FORCE_OVERWRITE" = "true" ]; then
  echo "⚠️  Force overwrite mode: ON"
fi
echo ""

# 既存のMCPサーバー一覧を取得
echo "📋 Checking existing MCP servers..."
existing_servers=$(claude mcp list 2>/dev/null | grep -E "^[a-zA-Z0-9_-]+:" | cut -d: -f1 || echo "")

# 既存サーバーを表示
echo "$existing_servers" | while IFS= read -r server; do
  if [ -n "$server" ]; then
    echo "  ⚠️  Already exists: $server"
  fi
done
echo ""

# サーバーが既存リストに含まれるかチェックする関数
is_server_existing() {
  local server_name="$1"
  echo "$existing_servers" | grep -q "^${server_name}$"
  return $?
}

# 環境変数の値をopコマンドに置き換える関数
resolve_op_reference() {
  local value="$1"

  if [[ $value == op://* ]]; then
    resolved=$(op read "$value" 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo "$resolved"
    else
      echo "Error: Failed to resolve $value" >&2
      echo "$value"
    fi
  else
    echo "$value"
  fi
}

# PWDをカレントディレクトリに置き換える関数
resolve_pwd_reference() {
  local value="$1"
  local current_dir="$PWD"

  # ${PWD} または $PWD を実際のパスに置き換え
  value="${value//\$\{PWD\}/$current_dir}"
  value="${value//\$PWD/$current_dir}"

  # $() 内のコマンドを実行して結果に置き換え
  local pattern='[$][(]([^)]+)[)]'
  while [[ $value =~ $pattern ]]; do
    local cmd="${BASH_REMATCH[1]}"
    local result=$(eval "$cmd" 2>/dev/null)
    if [ $? -eq 0 ]; then
      value="${value//\$($cmd)/$result}"
    else
      echo "Error: Failed to execute command: $cmd" >&2
      break
    fi
  done

  echo "$value"
}

# 結果を記録する一時ファイル
TEMP_DIR=$(mktemp -d)
ADDED_FILE="$TEMP_DIR/added.txt"
UPDATED_FILE="$TEMP_DIR/updated.txt"
SKIPPED_FILE="$TEMP_DIR/skipped.txt"
FAILED_FILE="$TEMP_DIR/failed.txt"

# クリーンアップ関数
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# サーバーリストを取得
server_list=$(jq -r '.mcpServers | keys[]' "$MCP_CONFIG")

# 各MCPサーバーを処理
while IFS= read -r server_name; do
  [ -z "$server_name" ] && continue

  echo "📦 Processing: $server_name"

  # 既に存在する場合の処理
  if is_server_existing "$server_name"; then
    if [ "$FORCE_OVERWRITE" = "true" ]; then
      echo "  🔄 Removing existing server to update..."
      if claude mcp remove "$server_name" 2>/dev/null; then
        echo "  ✓ Removed successfully"
      else
        echo "  ❌ Failed to remove: $server_name"
        echo "$server_name" >>"$FAILED_FILE"
        echo ""
        continue
      fi
    else
      echo "  ⏭️  Skipping: $server_name (already added)"
      echo "     Use --force to overwrite"
      echo "$server_name" >>"$SKIPPED_FILE"
      echo ""
      continue
    fi
  fi

  # サーバー設定を取得
  server_config=$(jq -c ".mcpServers.\"$server_name\"" "$MCP_CONFIG")

  # envオブジェクトがあるか確認
  has_env=$(echo "$server_config" | jq 'has("env")')

  if [ "$has_env" = "true" ]; then
    # 環境変数のリストを取得
    env_keys=$(echo "$server_config" | jq -r '.env | keys[]')
    new_env="{}"

    # 各環境変数を処理
    while IFS= read -r key; do
      [ -z "$key" ] && continue

      value=$(echo "$server_config" | jq -r ".env.\"$key\"")

      # op:// で始まる場合は1Passwordから取得
      if [[ $value == op://* ]]; then
        echo "  🔑 Resolving: $key"
        value=$(resolve_op_reference "$value")
      fi

      # $PWD や $() を解決
      value=$(resolve_pwd_reference "$value")

      new_env=$(echo "$new_env" | jq --arg k "$key" --arg v "$value" '.[$k] = $v')
    done <<<"$env_keys"

    server_config=$(echo "$server_config" | jq --argjson env "$new_env" '.env = $env')
  fi

  # claude mcp add-json コマンドを実行
  was_existing=false
  is_server_existing "$server_name" && was_existing=true

  if claude mcp add-json "$server_name" "$server_config" 2>/dev/null; then
    if [ "$was_existing" = "true" ]; then
      echo "  ✅ Successfully updated: $server_name"
      echo "$server_name" >>"$UPDATED_FILE"
    else
      echo "  ✅ Successfully added: $server_name"
      echo "$server_name" >>"$ADDED_FILE"
    fi
  else
    echo "  ❌ Failed to add: $server_name"
    echo "$server_name" >>"$FAILED_FILE"
  fi
  echo ""
done <<<"$server_list"

# 結果サマリーを表示
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Processing complete!"
echo ""

# 追加されたサーバー
if [ -f "$ADDED_FILE" ] && [ -s "$ADDED_FILE" ]; then
  added_count=$(wc -l <"$ADDED_FILE" | tr -d ' ')
  echo "✅ Added ($added_count):"
  while IFS= read -r server; do
    echo "   • $server"
  done <"$ADDED_FILE"
  echo ""
fi

# 更新されたサーバー
if [ -f "$UPDATED_FILE" ] && [ -s "$UPDATED_FILE" ]; then
  updated_count=$(wc -l <"$UPDATED_FILE" | tr -d ' ')
  echo "🔄 Updated ($updated_count):"
  while IFS= read -r server; do
    echo "   • $server"
  done <"$UPDATED_FILE"
  echo ""
fi

# スキップされたサーバー
if [ -f "$SKIPPED_FILE" ] && [ -s "$SKIPPED_FILE" ]; then
  skipped_count=$(wc -l <"$SKIPPED_FILE" | tr -d ' ')
  echo "⏭️  Skipped ($skipped_count):"
  while IFS= read -r server; do
    echo "   • $server"
  done <"$SKIPPED_FILE"
  echo ""
fi

# 失敗したサーバー
if [ -f "$FAILED_FILE" ] && [ -s "$FAILED_FILE" ]; then
  failed_count=$(wc -l <"$FAILED_FILE" | tr -d ' ')
  echo "❌ Failed ($failed_count):"
  while IFS= read -r server; do
    echo "   • $server"
  done <"$FAILED_FILE"
  echo ""
fi

# 総合カウント
added_count=0
updated_count=0
skipped_count=0
failed_count=0
[ -f "$ADDED_FILE" ] && added_count=$(wc -l <"$ADDED_FILE" | tr -d ' ')
[ -f "$UPDATED_FILE" ] && updated_count=$(wc -l <"$UPDATED_FILE" | tr -d ' ')
[ -f "$SKIPPED_FILE" ] && skipped_count=$(wc -l <"$SKIPPED_FILE" | tr -d ' ')
[ -f "$FAILED_FILE" ] && failed_count=$(wc -l <"$FAILED_FILE" | tr -d ' ')

total=$((added_count + updated_count + skipped_count + failed_count))
echo "📊 Total processed: $total servers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 失敗があった場合は終了コードを1にする
if [ -f "$FAILED_FILE" ] && [ -s "$FAILED_FILE" ]; then
  exit 1
fi
