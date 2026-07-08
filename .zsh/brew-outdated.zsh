# brew の更新可能パッケージ件数をキャッシュへ集計する（表示は p10k の brew_outdated セグメント）。
# Why: brew outdated は数秒かかりプロンプト内で直接実行できないため、TTL 切れのときだけ
#      バックグラウンドで再集計し、プロンプト側はキャッシュを読むだけにする。
#      formula メタデータ自体は brew autoupdate（launchd）が毎日更新している前提。

if type brew &>/dev/null; then
  zmodload zsh/datetime
  zmodload -F zsh/stat b:zstat

  BREW_OUTDATED_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/brew-outdated-count"
  BREW_OUTDATED_TTL=$((6 * 3600))

  # バックグラウンドで件数を再集計する。先に touch して TTL をリセットすることで
  # 並行シェルからの多重起動を抑える（集計失敗時は次の TTL 切れで再試行）。
  brew-outdated-refresh() {
    mkdir -p "${BREW_OUTDATED_CACHE:h}"
    touch "$BREW_OUTDATED_CACHE"
    # ( ... & ) の二重括弧は、ジョブ通知([1] 12345)を出さずに切り離すための定石。
    # メタデータ更新は brew autoupdate に任せているため NO_AUTO_UPDATE で集計を速くする。
    (
      {
        out=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null) || exit
        lines=(${(f)out})
        tmp=$(mktemp "${BREW_OUTDATED_CACHE}.XXXXXX") || exit
        print -r -- "${#lines}" > "$tmp" && mv -f "$tmp" "$BREW_OUTDATED_CACHE"
      } &
    ) >/dev/null 2>&1
  }

  _brew_outdated_precmd() {
    local -a mtime
    if ! zstat -A mtime +mtime "$BREW_OUTDATED_CACHE" 2>/dev/null \
        || (( EPOCHSECONDS - mtime[1] > BREW_OUTDATED_TTL )); then
      brew-outdated-refresh
    fi
  }

  # パッケージ構成が変わる brew 操作を検知したらキャッシュを破棄し、
  # 次のプロンプトで再集計させる（upgrade 後に表示がすぐ消えるようにする）
  _brew_outdated_preexec() {
    [[ "$1" == brew\ (upgrade|install|uninstall|remove|rm|reinstall)* ]] \
      && rm -f "$BREW_OUTDATED_CACHE"
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _brew_outdated_precmd
  add-zsh-hook preexec _brew_outdated_preexec
fi
