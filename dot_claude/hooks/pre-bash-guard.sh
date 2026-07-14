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

# rm は正規表現でなく解析で判定する。検知対象は再帰削除のみ（-f 単体は素の rm と
# 危険度が同じ）とし、全ターゲットが一時領域配下と証明できれば素通しする。
# 同一コマンド内の変数代入と cd を追跡し、安全と証明できないもの（未知変数・
# 相対パスで現在位置不明・xargs 等のラッパー経由）は ask に倒す（fail-closed）。
# 入口は従来どおり scrubbed で判定し、コミットメッセージ内の "rm -rf" 誤検知を防ぐ。
if [ -z "$reason" ] && printf '%s' "$scrubbed" | grep -Eq '(^|[[:space:];&|(])rm[[:space:]]'; then
  cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
  unsafe=$(printf '%s' "$cmd" | awk -v cwd="$cwd" -v home="$HOME" '
    # 安全と証明できない再帰 rm を見つけたら "unsafe" を出力する。
    # セグメント（; & | 改行区切り）単位で変数代入と cd を追跡し、rm のターゲットを
    # 一時領域プレフィックスと突き合わせる。

    # クォート文字の除去（空白入りパスは分割で崩れるが ask 側に倒れるため許容）
    function unq(s) { gsub(/["'\'']/, "", s); return s }

    # 先頭の ~ / $VAR / ${VAR} を解決してパスを返す。解決不能は ""。
    # ターゲット文脈（tmpok=1）では $TMPDIR 先頭を展開せず一時領域確定 "@SAFE" とする
    function resolve(t, tmpok,   name, rest) {
      t = unq(t)
      if (tmpok && (index(t, "$TMPDIR") == 1 || index(t, "${TMPDIR") == 1)) return "@SAFE"
      if (t == "~") t = home
      else if (index(t, "~/") == 1) t = home substr(t, 2)
      else if (substr(t, 1, 1) == "~") return ""
      if (substr(t, 1, 1) == "$") {
        if (match(t, /^\$\{[A-Za-z_][A-Za-z0-9_]*\}/)) { name = substr(t, 3, RLENGTH - 3); rest = substr(t, RLENGTH + 1) }
        else if (match(t, /^\$[A-Za-z_][A-Za-z0-9_]*/)) { name = substr(t, 2, RLENGTH - 1); rest = substr(t, RLENGTH + 1) }
        else return ""
        if (name == "HOME") t = home rest
        else if (name in vars) t = vars[name] rest
        else return ""
      }
      if (index(t, "$")) return ""   # 途中の $ は .. への展開があり得るため解決不能扱い
      return t
    }

    # 一時領域プレフィックスより深い階層を指すか（/tmp/ そのもの等は不可）
    function is_safe(t) {
      sub(/\/+$/, "", t)
      if (index(t, "/tmp/") == 1) return 1
      if (index(t, "/private/tmp/") == 1) return 1
      if (index(t, "/var/folders/") == 1) return 1
      if (index(t, "/private/var/folders/") == 1) return 1
      if (home != "" && index(t, home "/.cache/") == 1) return 1
      return 0
    }

    function check_rm(tok, m,   j, t, rec, dd, skipnext, nt, targets, k) {
      rec = 0; dd = 0; skipnext = 0; nt = 0
      for (j = 2; j <= m; j++) {
        t = tok[j]
        if (skipnext) { skipnext = 0; continue }
        # リダイレクトはターゲットでない。演算子単体なら直後のパスも読み飛ばす
        if (t ~ /^[0-9]*(>>?|<)/) { if (t ~ /^[0-9]*(>>?|<)$/) skipnext = 1; continue }
        if (!dd && t == "--") { dd = 1; continue }
        if (!dd && substr(t, 1, 1) == "-") {
          if (t ~ /^-[A-Za-z]*[rR]/ || t == "--recursive") rec = 1
          continue
        }
        targets[++nt] = t
      }
      if (!rec) return
      for (k = 1; k <= nt; k++) {
        t = resolve(targets[k], 1)
        if (t == "@SAFE") continue
        if (t == "") { bad = 1; return }
        if (substr(t, 1, 1) != "/") {
          if (cur == "") { bad = 1; return }
          t = cur "/" t
        }
        if (index(t, "..")) { bad = 1; return }
        if (!is_safe(t)) { bad = 1; return }
      }
    }

    function do_cd(tok, m,   t) {
      if (m == 1) { cur = home; return }
      if (m > 2 || tok[2] == "-") { cur = ""; return }
      t = resolve(tok[2], 0)
      if (t == "" || index(t, "..")) { cur = ""; return }
      if (substr(t, 1, 1) == "/") cur = t
      else if (cur != "") cur = cur "/" t
    }

    BEGIN { cur = cwd }
    { buf = buf $0 "\n" }
    END {
      # サブシェル/コマンド置換内の cd は後続セグメントへ波及しないため追跡できない。
      # ( と cd が共存するコマンドは現在位置を不明化する（fail-closed）
      if (index(buf, "(") && buf ~ /(^|[ \t;&|(\n])cd([ \t;&|\n]|$)/) cur = ""
      n = split(buf, segs, /[;&|\n]+/)
      for (i = 1; i <= n; i++) {
        seg = segs[i]
        sub(/^[ \t]+/, "", seg)
        sub(/[ \t]+$/, "", seg)
        if (seg == "") continue
        m = split(seg, tok, /[ \t]+/)
        head = tok[1]
        if (head == "rm" || head ~ /\/rm$/) { check_rm(tok, m); continue }
        # ラッパー検知: rm 以外のコマンドの引数に rm が語として現れる（xargs rm、
        # find -exec rm 等）とターゲットを検証できないため unsafe
        s = seg
        gsub(/"[^"]*"/, "", s)
        gsub(/'\''[^'\'']*'\''/, "", s)
        if (s ~ /(^|[ \t(])rm([ \t]|$)/) { bad = 1; continue }
        if (head == "cd") { do_cd(tok, m); continue }
        # 単独の変数代入セグメントを記録（値を解決できるものだけ）
        if (m == 1 && head ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
          eq = index(head, "=")
          t = resolve(substr(head, eq + 1), 0)
          if (t != "") vars[substr(head, 1, eq - 1)] = t
        }
      }
      if (bad) print "unsafe"
    }
  ')
  [ -n "$unsafe" ] && reason='rm による再帰削除（一時領域外）'
fi

if [ -n "$reason" ]; then
  # PreToolUse の ask 起因の許可プロンプトでは Notification イベントが発火せず
  # notify.sh が呼ばれないため、ここで直接通知する（原則4: awareness）。
  tmux_info=$(tmux display-message -p -t "$TMUX_PANE" '#S:#W' 2>/dev/null)
  terminal-notifier -title "Claude Code: ${tmux_info}" -message "確認が必要: ${reason}" -sound default >/dev/null 2>&1
  jq -n --arg r "$reason" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: ("確認が必要: " + $r)}}'
fi
exit 0
