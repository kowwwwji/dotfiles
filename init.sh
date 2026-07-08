#!/bin/zsh

DOTFILES_ROOT=$(ghq root)/github.com/kowwwwji/dotfiles

# ドットファイルのシンボリックリンク作成
# 注: .gitignore はこのリポジトリ専用のため $HOME に張らない（global 用は .gitignore_global）。
for i in ./.* ; do
  [[ "$i" == "./." || "$i" == "./.." || "$i" == "./init.sh" || "$i" == "./.gitignore" ]] && continue
  [[ -f "$i" ]] && ln -nfs "${DOTFILES_ROOT}/${i##./}" "${HOME}/${i##./}"
done
# 旧構成（repo の .gitignore を global 兼用で ~/.gitignore に張っていた）の名残は
# 誤参照のもとになるため掃除する。
[[ -L "${HOME}/.gitignore" ]] && rm "${HOME}/.gitignore"

# vim
mkdir -p "${HOME}/.config/vim/"
ln -nfs "${DOTFILES_ROOT}/.config/vim/plugins" "${HOME}/.config/vim/"
ln -nfs "${DOTFILES_ROOT}/.config/vim/UltiSnips" "${HOME}/.config/vim/"
ln -nfs "${DOTFILES_ROOT}/.config/vim/coc-settings.json" "${HOME}/.config/vim/coc-settings.json"

# lazy
mkdir -p "${HOME}/.config/lazydocker"
mkdir -p "${HOME}/.config/lazygit"
ln -nfs "${DOTFILES_ROOT}/.config/lazydocker/config.yml" "${HOME}/.config/lazydocker/config.yml"
ln -nfs "${DOTFILES_ROOT}/.config/lazygit/config.yml" "${HOME}/.config/lazygit/config.yml"
ln -nfs "${DOTFILES_ROOT}/.config/lazygit/scripts" "${HOME}/.config/lazygit/"

# programing
ln -nfs "${DOTFILES_ROOT}/.config/nvim" "${HOME}/.config/"
ln -nfs "${DOTFILES_ROOT}/.config/sheldon" "${HOME}/.config/"
ln -nfs "${DOTFILES_ROOT}/.config/wezterm" "${HOME}/.config/"
# memo: 旧構成の名残で ~/.config/memo がディレクトリごと repo への symlink だと、
# ln がリンクを貫通して repo 側の実ファイルを自己参照リンクに置き換えてしまう。
# 実ディレクトリに正してから file 単位でリンクする。
[[ -L "${HOME}/.config/memo" ]] && rm "${HOME}/.config/memo"
mkdir -p "${HOME}/.config/memo"
ln -nfs "${DOTFILES_ROOT}/.config/memo/config.toml" "${HOME}/.config/memo/config.toml"

mkdir -p "${HOME}/.config/karabiner/assets"
# karabiner.json は symlink せず sync で配布（Karabiner が保存時にファイルを置き換えて
# symlink が切れるため。詳細は CLAUDE.md）。jq 未導入時の扱いは claude-settings-sync と同じ。
if command -v jq >/dev/null 2>&1; then
  sh "${DOTFILES_ROOT}/.scripts/karabiner-settings-sync"
else
  echo "jq が未インストールのため karabiner-settings-sync をスキップ（brew bundle 後に再実行してください）"
fi
ln -nfs "${DOTFILES_ROOT}/.config/karabiner/assets/complex_modifications" "${HOME}/.config/karabiner/assets/complex_modifications"

mkdir -p "${HOME}/.config/git/"
touch "${HOME}/.config/git/.gitconfig.local"
mkdir -p "${HOME}/.ssh"
touch "${HOME}/.ssh/config"

ln -nfs "${DOTFILES_ROOT}/.zsh" "$HOME"
ln -nfs "${DOTFILES_ROOT}/.scripts" "$HOME"

# VSCode
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
if [[ -d "$VSCODE_USER_DIR" ]]; then
  for i in ./.vscode/*; do
    cp "${DOTFILES_ROOT}/${i#./}" "$VSCODE_USER_DIR${i##./.vscode}"
  done
fi

# claude
mkdir -p "${HOME}/.claude/hooks"
ln -nfs "${DOTFILES_ROOT}/dot_claude/skills" "${HOME}/.claude/skills"
ln -nfs "${DOTFILES_ROOT}/dot_claude/rules" "${HOME}/.claude/rules"
ln -nfs "${DOTFILES_ROOT}/dot_claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
# settings.json は symlink せずマージ生成（Claude Code が /model 等を書き込むため。詳細は CLAUDE.md）
# 注: jq は brew bundle で入るため、フレッシュPCでは init.sh 時点で未インストール。
#     その場合はスキップし、brew bundle 後に `.scripts/claude-settings-sync` を再実行すれば効く。
if command -v jq >/dev/null 2>&1; then
  sh "${DOTFILES_ROOT}/.scripts/claude-settings-sync"
else
  echo "jq が未インストールのため claude-settings-sync をスキップ（brew bundle 後に再実行してください）"
fi
ln -nfs "${DOTFILES_ROOT}/dot_claude/statusline-command.sh" "${HOME}/.claude/statusline-command.sh"
# agents: 汎用 agent は ~/.claude/agents/ へ個別リンク（ローカル専用 agent も同居するため。
# 新規追加時はここに1行足す）。このリポジトリ専用 agent（dotfiles-reviewer 等）は
# .claude/agents/ に実体を置くのでリンク不要。
mkdir -p "${HOME}/.claude/agents"
ln -nfs "${DOTFILES_ROOT}/dot_claude/agents/code-reviewer.md" "${HOME}/.claude/agents/code-reviewer.md"
ln -nfs "${DOTFILES_ROOT}/dot_claude/agents/security-auditor.md" "${HOME}/.claude/agents/security-auditor.md"
# 旧構成（dotfiles-reviewer を ~/.claude/agents/ へ張っていた）のダングリングリンクを掃除する。
[[ -L "${HOME}/.claude/agents/dotfiles-reviewer.md" ]] && rm "${HOME}/.claude/agents/dotfiles-reviewer.md"
# hooks: dot_claude/hooks/ 配下は個別リンク（新規追加時はここに1行足す）
ln -nfs "${DOTFILES_ROOT}/dot_claude/hooks/notify.sh" "${HOME}/.claude/hooks/notify.sh"
ln -nfs "${DOTFILES_ROOT}/dot_claude/hooks/stop.sh" "${HOME}/.claude/hooks/stop.sh"
ln -nfs "${DOTFILES_ROOT}/dot_claude/hooks/session-start.sh" "${HOME}/.claude/hooks/session-start.sh"
ln -nfs "${DOTFILES_ROOT}/dot_claude/hooks/pre-bash-guard.sh" "${HOME}/.claude/hooks/pre-bash-guard.sh"
ln -nfs "${DOTFILES_ROOT}/dot_claude/hooks/require-worktree.sh" "${HOME}/.claude/hooks/require-worktree.sh"
ln -nfs "${DOTFILES_ROOT}/dot_claude/hooks/ask-notify.sh" "${HOME}/.claude/hooks/ask-notify.sh"

# mise: .tool-versions の言語ランタイム + Go製CLIツールを導入
# config は mise 未導入でも先に配置する（brew bundle 後の mise がそのまま読めるように）
mkdir -p "${HOME}/.config/mise"
ln -nfs "${DOTFILES_ROOT}/.config/mise/config.toml" "${HOME}/.config/mise/config.toml"
# 注: mise は brew bundle で入るため、フレッシュPCでは init.sh 時点で未インストール。
#     その場合はスキップし、brew bundle 後に init.sh を再実行（または `mise install`）すれば効く。
if command -v mise >/dev/null 2>&1; then
  # mise は config を実体パスで信頼管理するため、symlink 先のリポジトリパスを明示的に trust する
  # （デフォルト信頼パスは ~/.config/mise 直下のみ。trust しないと mise install が失敗する）
  mise trust "${DOTFILES_ROOT}/.config/mise/config.toml"
  mise install
else
  echo "mise が未インストールのため mise install をスキップ（brew bundle 後に再実行してください）"
fi

# gh: gh-dash 設定の配置と拡張のインストール
mkdir -p "${HOME}/.config/gh-dash"
ln -nfs "${DOTFILES_ROOT}/.config/gh-dash/config.yml" "${HOME}/.config/gh-dash/config.yml"
# 注: gh は brew bundle で入り、拡張のインストールには gh の認証が必要。
#     フレッシュPCでは brew bundle と gh auth login 後に init.sh を再実行すれば入る。
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh extension list 2>/dev/null | grep -q 'dlvhdr/gh-dash' || gh extension install dlvhdr/gh-dash
else
  echo "gh が未導入または未認証のため gh extension install をスキップ（gh auth login 後に再実行してください）"
fi

# tmux
TPM_ROOT="${HOME}/.tmux/plugins/tpm"
[[ ! -e "$TPM_ROOT" ]] && git clone https://github.com/tmux-plugins/tpm "$TPM_ROOT"
mkdir -p "${HOME}/.tmux"
ln -nfs "${DOTFILES_ROOT}/.tmux/.tmux.dev.conf" "${HOME}/.tmux/.tmux.dev.conf"
ln -nfs "${DOTFILES_ROOT}/.tmux/git-status.sh" "${HOME}/.tmux/git-status.sh"
ln -nfs "${DOTFILES_ROOT}/.tmux/session-alerts.sh" "${HOME}/.tmux/session-alerts.sh"
ln -nfs "${DOTFILES_ROOT}/.tmux/reload.sh" "${HOME}/.tmux/reload.sh"

# tmux-which-key: メニュー定義をリポジトリ管理の実体へ向ける
# 注: plugin ディレクトリ内の config.yaml は plugin 側で gitignore された
#     カスタマイズ用パス。plugin 本体は tmux 内で prefix+I (TPM) で入るため、
#     フレッシュPCではプラグインインストール後に init.sh を再実行すれば張られる。
WHICH_KEY_ROOT="${HOME}/.tmux/plugins/tmux-which-key"
if [[ -d "$WHICH_KEY_ROOT" ]]; then
  ln -nfs "${DOTFILES_ROOT}/.tmux/which-key.yaml" "${WHICH_KEY_ROOT}/config.yaml"
else
  echo "tmux-which-key が未インストールのため config.yaml の symlink をスキップ（tmux で prefix+I 後に再実行してください）"
fi
