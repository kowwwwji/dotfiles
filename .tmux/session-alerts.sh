#!/bin/sh
# 他セッションの通知(bell/silence)をステータスバー向けに列挙する。
# .tmux.conf の status-right から #() で呼ばれる。
# 引数1: 現在のクライアントのセッション名(#{client_session})。
#        自セッションは中央の window 一覧で通知が見えるため除外。popup も除外。
# 出力: セッションごとに「アイコン セッション名」を色付きで連結(各entry末尾に区切りの2スペース)。
#       ベル > サイレントの優先度で1セッション1entry。window 一覧と同じ色言語。
#       通知が無ければ何も出力しない。依存は tmux と POSIX 基本コマンドのみ。

current="$1"

# 色は .tmux.conf の palette(@c-*)を単一ソースにする
c_info=$(tmux show-option -gqv @c-info)
c_silence=$(tmux show-option -gqv @c-silence)

bell_sessions=$(tmux list-windows -a -f '#{window_bell_flag}' -F '#{session_name}' 2>/dev/null | sort -u)
silence_sessions=$(tmux list-windows -a -f '#{window_silence_flag}' -F '#{session_name}' 2>/dev/null | sort -u)

out=""
for s in $bell_sessions; do
  case "$s" in "$current" | popup) continue ;; esac
  out="${out}#[fg=${c_info}]󱅫 ${s}#[default]  "
done
for s in $silence_sessions; do
  case "$s" in "$current" | popup) continue ;; esac
  # ベルで表示済みのセッションは重複させない(ベル優先)
  printf '%s\n' "$bell_sessions" | grep -Fqx "$s" && continue
  out="${out}#[fg=${c_silence}]󰂛 ${s}#[default]  "
done

printf '%s' "$out"
