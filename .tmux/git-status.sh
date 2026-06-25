#!/bin/sh
# tmux status用 gitセグメント（要素ごとに色分け）
# 使い方: git-status.sh <path>   (通常は #{pane_current_path} を渡す)
# 出力例:  master ↑2 +1 !2 ?3   (gitリポジトリ外なら何も出さない)

# ── 色設定（tmuxの #[fg=...] 記法。ここを変えれば配色が変わる） ──────────────────
C_BRANCH="#87afd7"     # ブランチ名: 青
C_AHEAD="#00d7d7"      # ahead/behind ↑↓: シアン
C_STAGED="#87af5f"     # staged + : 緑
C_UNSTAGED="#d7af5f"   # unstaged ! : 黄
C_UNTRACKED="#808080"  # untracked ? : グレー

dir="${1:-$PWD}"

# ブランチ（detached時は短縮ハッシュ）
if branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
  :
elif commit=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  branch="@${commit}"
else
  exit 0   # git管理外 → 空出力
fi

extra=""

# upstream比較 ahead/behind（0は非表示）
if counts=$(git -C "$dir" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
  behind=$(echo "$counts" | cut -f1)
  ahead=$(echo "$counts" | cut -f2)
  [ "$ahead" -gt 0 ]  && extra="${extra}#[fg=${C_AHEAD}] ↑${ahead}"
  [ "$behind" -gt 0 ] && extra="${extra}#[fg=${C_AHEAD}] ↓${behind}"
fi

# staged(+) / unstaged(!) / untracked(?)（0は非表示）
status=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)
staged=$(echo "$status" | grep -c '^[MADRC]')
unstaged=$(echo "$status" | grep -c '^.[MD]')
untracked=$(echo "$status" | grep -c '^??')
[ "$staged" -gt 0 ]    && extra="${extra}#[fg=${C_STAGED}] +${staged}"
[ "$unstaged" -gt 0 ]  && extra="${extra}#[fg=${C_UNSTAGED}] !${unstaged}"
[ "$untracked" -gt 0 ] && extra="${extra}#[fg=${C_UNTRACKED}] ?${untracked}"

printf '#[fg=%s] %s%s#[default]' "$C_BRANCH" "$branch" "$extra"
