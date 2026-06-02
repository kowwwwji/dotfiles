#!/bin/sh
# Claude Code statusLine — mirrors Powerlevel10k lean prompt elements:
#   Left:  os_icon · dir · vcs (branch + status)
#   Right: context (user@host) · time · model · context-window

input=$(cat)

# ── dir ──────────────────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
# Replace $HOME with ~
home="$HOME"
dir="${cwd/#$home/\~}"

# ── vcs (git) ─────────────────────────────────────────────────────────────────
branch=""
git_extra=""
if git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
  branch=" $git_branch"
  # staged (+), unstaged (!), untracked (?)
  git_status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(echo "$git_status" | grep -c '^[MADRC]' 2>/dev/null)
  unstaged=$(echo "$git_status" | grep -c '^.[MD]' 2>/dev/null)
  untracked=$(echo "$git_status" | grep -c '^??' 2>/dev/null)
  [ "$staged" -gt 0 ]    && git_extra="${git_extra} +${staged}"
  [ "$unstaged" -gt 0 ]  && git_extra="${git_extra} !${unstaged}"
  [ "$untracked" -gt 0 ] && git_extra="${git_extra} ?${untracked}"
elif git_commit=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  branch=" @${git_commit}"
fi

# ── context (user@host) ───────────────────────────────────────────────────────
context="$(whoami)@$(hostname -s)"

# ── time ──────────────────────────────────────────────────────────────────────
time_now=$(date +%H:%M:%S)

# ── model ─────────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // .model.id // ""')

# ── context window ────────────────────────────────────────────────────────────
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_str=""
[ -n "$remaining" ] && ctx_str=" ctx:${remaining}%"

# ── assemble ──────────────────────────────────────────────────────────────────
# Left side:  dir  branch git_extra
# Right side: context  time  model  ctx
left="${dir}${branch}${git_extra}"
right="${context}  ${time_now}  ${model}${ctx_str}"

printf '%s  |  %s\n' "$left" "$right"
