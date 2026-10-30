-- snacks picker（LazyVim 既定のファイル検索・grep）で隠しファイルを常に表示する。
-- snacks の既定は hidden = false で、dotfiles のように `.` 始まりが大半のリポジトリでは
-- ほぼ何も出ないため。.gitignore 対象（ignored）は従来どおり除外し、必要なときは
-- ピッカー内の Alt-i で切り替える（Alt-h で hidden も一時的に戻せる）。
-- .git ディレクトリは snacks 側で常に除外されるので、hidden を有効にしても出てこない。
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        grep_word = { hidden = true },
        explorer = { hidden = true },
      },
    },
  },
}
