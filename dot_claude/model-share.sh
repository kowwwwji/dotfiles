#!/bin/sh
# ローカル transcript から「特定モデルがトークン消費のどれだけを占めるか」を集計し、
# ~/.claude/cache/model-share.json に書き出す（statusline はこのキャッシュを読むだけ）。
#
# 使い方: model-share.sh [集計起点のunix秒]   （省略時は 7日前）
#   statusline からは rate_limits.seven_day.resets_at - 7日 を渡す。「直近7日」ではなく
#   公式の週次ウィンドウと同じ期間を測るため。
#
# NOTE: statusline に渡る JSON の rate_limits は five_hour / seven_day の2つだけで、
#   モデル別の内訳は入ってこない。正確な内訳は /api/oauth/usage にあるが、叩くには
#   Keychain の OAuth トークンが要る非公式 IF で Claude Code の更新に追随できない。
#   よって公式に取れる全体の使用率を、ローカル transcript のシェアで按分する。出るのは推定値。
# NOTE: 重みはモデル共通の構造比（cache write 1.25 / cache read 0.1 / output 5）だけを使い、
#   モデル別の単価は掛けない。単価表を持つと改定・新モデルのたびに嘘になるため。
#   代償としてモデル間の単価差は無視する（Opus と Haiku の 1 トークンを同じ重さで数える）。

# 対象モデルはプレフィックス一致で判定する。`claude-fable-5` 決め打ちにすると
# 次のバージョンが出た瞬間に無言で 0% になるため。
MODEL_PREFIX='claude-fable-'

PROJECTS_DIR="${HOME}/.claude/projects"
CACHE_DIR="${HOME}/.claude/cache"
CACHE_FILE="${CACHE_DIR}/model-share.json"
LOCK_DIR="${CACHE_DIR}/model-share.lock"

command -v jq >/dev/null 2>&1 || exit 1
[ -d "$PROJECTS_DIR" ] || exit 1

now=$(date +%s)
since=${1:-$(( now - 7 * 24 * 3600 ))}
case "$since" in ''|*[!0-9]*) exit 1 ;; esac
# transcript の timestamp は UTC の ISO8601 固定長。epoch へ変換せず文字列比較で絞る
# （行ごとの日付パースをやめる分だけ速い）。
since_iso=$(date -u -r "$since" +%Y-%m-%dT%H:%M:%SZ) || exit 1

mkdir -p "$CACHE_DIR" || exit 1

# 多重起動の抑止。mkdir はアトミックなので取れた1本だけが集計し、他は即座に諦める
# （statusline は毎レンダーでキックしうるため）。異常終了で残った古いロックは掃除して取り直す。
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  [ -n "$(find "$LOCK_DIR" -maxdepth 0 -mmin +10 2>/dev/null)" ] || exit 0
  rmdir "$LOCK_DIR" 2>/dev/null
  mkdir "$LOCK_DIR" 2>/dev/null || exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null; exit 1' INT TERM HUP
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# 集計。jq -s（slurp）で全行を配列化すると数分かかって使いものにならないため、
# grep で assistant 行に前絞りしてから jq -R でストリーム処理する。
# 一部の行に不正なサロゲートペアが混ざっており素の jq はそこで死ぬので、
# fromjson? // empty で壊れた行を読み飛ばす。
# 二重計上を3か所で避ける:
#   - usage.iterations[] は同じ数字の再掲なのでトップレベルの usage だけを見る
#   - 1つの応答は content block（thinking/text/tool_use）ごとに別行で記録され、
#     どの行も同じ usage を持つ
#   - 再開・fork したセッションは過去の行を別ファイルへ複写する
#   後ろ2つは message.id が同じなので、id 単位で最初の1件だけ数える。
json=$(
  find "$PROJECTS_DIR" -type f -name '*.jsonl' -mtime -8 \
      -exec grep -h '"type":"assistant"' {} + 2>/dev/null |
    jq -Rr --arg since "$since_iso" '
      fromjson? // empty
      | objects
      | select(.type == "assistant" and .timestamp >= $since)
      | (.message | objects) as $m
      | ($m.usage | objects) as $u
      | [ ($m.id // .uuid // "-"),
          ($m.model // ""),
          ($u.input_tokens // 0),
          ($u.cache_creation_input_tokens // 0),
          ($u.cache_read_input_tokens // 0),
          ($u.output_tokens // 0) ]
      | @tsv' 2>/dev/null |
    awk -F'\t' -v prefix="$MODEL_PREFIX" -v now="$now" -v since="$since" '
      !seen[$1]++ {
        weighted = $3 + 1.25 * $4 + 0.1 * $5 + 5 * $6
        total += weighted
        if (index($2, prefix) == 1) target += weighted
      }
      END {
        # 対象期間に1件も無いときは share を出さない（ゼロ除算・嘘の 0% を避ける）
        if (total <= 0) exit 1
        printf "{\"generated_at\":%d,\"since\":%d,\"model_prefix\":\"%s\",\"share\":%.4f}\n", \
          now, since, prefix, target / total
      }'
) || exit 1
[ -n "$json" ] || exit 1

# 読み手（statusline）が半端な内容を掴まないよう、書いてから差し替える
tmp="${CACHE_FILE}.$$"
printf '%s\n' "$json" > "$tmp" && mv -f "$tmp" "$CACHE_FILE" || { rm -f "$tmp"; exit 1; }

printf '%s\n' "$json"
