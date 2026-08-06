#!/bin/sh
# モデル個別の週次上限（例: Fable）を取得して ~/.claude/cache/usage-limits.json に書く。
# statusline はこのキャッシュを読むだけ（API を待たせない）。
#
# NOTE: statusline に渡る JSON の rate_limits は five_hour / seven_day の2つだけで、
#   モデル個別の上限は入ってこない。/usage 画面が使っているのと同じ
#   GET /api/oauth/usage にしか無いため、ここだけ自前で叩く。
# NOTE: これは Claude Code 内部の非公式 IF で、更新で予告なく壊れうる。
#   壊れたら「モデル個別の表示が消えるだけ」で済むよう、失敗は全て黙って握りつぶす。
# NOTE: トークンはリフレッシュしない。自前でリフレッシュすると refresh token の
#   ローテーションで Claude Code 本体のログインを壊しかねないため。期限切れは失敗扱いにし、
#   本体が次にリフレッシュするのを待つ。

ENDPOINT='https://api.anthropic.com/api/oauth/usage'
KEYCHAIN_SERVICE='Claude Code-credentials'

CACHE_DIR="${HOME}/.claude/cache"
CACHE_FILE="${CACHE_DIR}/usage-limits.json"
LOCK_DIR="${CACHE_DIR}/usage-limits.lock"

command -v jq >/dev/null 2>&1 || exit 1
command -v curl >/dev/null 2>&1 || exit 1

mkdir -p "$CACHE_DIR" || exit 1

# 多重起動の抑止。mkdir はアトミックなので取れた1本だけが叩く（statusline は毎レンダーで
# キックしうる）。異常終了で残った古いロックは掃除して取り直す。
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  [ -n "$(find "$LOCK_DIR" -maxdepth 0 -mmin +10 2>/dev/null)" ] || exit 0
  rmdir "$LOCK_DIR" 2>/dev/null
  mkdir "$LOCK_DIR" 2>/dev/null || exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null; exit 1' INT TERM HUP
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# Claude Code 本体と同じ Keychain 項目から読む。トークンはこの変数の外へ出さない
# （キャッシュにも書かない・ログにも出さない）。
token=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null |
  jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
[ -n "$token" ] || exit 1
# curl の設定ファイルはクォート文字列なので、含まれると壊れる文字を弾く（正常なトークンには出ない）
case "$token" in *'"'*|*'\'*|*'
'*) exit 1 ;; esac

# 認証ヘッダはコマンドライン引数に置かず --config 経由で標準入力から渡す。
# 引数に書くと ps でトークンが他プロセスから見えるため。
resp=$(printf 'url = "%s"\nheader = "Authorization: Bearer %s"\nheader = "Content-Type: application/json"\nsilent\nmax-time = 5\n' \
  "$ENDPOINT" "$token" | curl --config - 2>/dev/null)
[ -n "$resp" ] || exit 1

# limits[] のうち kind == "weekly_scoped" がモデル個別の上限。特定モデル名で決め打ちせず
# 汎用に拾う（将来 Fable 以外に個別上限が付いたらそのまま出る）。
now=$(date +%s)
# limits が配列であることを成功の条件にする。エラー応答（{"type":"error",...}）や
# 想定外の形のときは何も出力させず、キャッシュを触らない（前回の正常値を消さないため）。
json=$(printf '%s' "$resp" | jq -c --argjson now "$now" '
  select(type == "object" and (.limits | type) == "array")
  | { generated_at: $now,
      scoped: [ .limits[]
                | select(type == "object" and .kind == "weekly_scoped")
                | { name: (.scope.model.display_name // empty),
                    percent: (.percent // empty),
                    severity: (.severity // "normal") }
                | select(.name != null and .percent != null) ] }' 2>/dev/null) || exit 1
[ -n "$json" ] || exit 1

# 読み手（statusline）が書きかけを掴まないよう、別名で書いてから差し替える
tmp="${CACHE_FILE}.$$"
printf '%s\n' "$json" > "$tmp" && mv -f "$tmp" "$CACHE_FILE" || { rm -f "$tmp"; exit 1; }

printf '%s\n' "$json"
