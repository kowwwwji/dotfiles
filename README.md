# Dotfiles
kowwwwji's DotFile & PC setup

## 環境構築

### システム環境設定の変更1
1. トラックパッドの`軌跡の速さ`を最大に
2. キーボード
  - `キーのリピート`と`リピート入力認識までの時間`を最大に。
  - F1F2をファンクションキーとして使用にチェック
  - ショートカットのSpotlight検索を表示をOFF
3. 音声入力のショートカットを`Fn`に
4. メニューバーの表示
  - Dockとメニューバー
    - bluetooth ON
    - バッテリー ON
      - バッテリーの％表示
    - Spotlight OFF

### Various Installs

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew install ghq
ghq get https://github.com/kowwwwji/dotfiles.git
cd $(ghq root)/github.com/kowwwwji/dotfiles

zsh init.sh # $HOMEへの適用
brew bundle # Application Install
# 以下はログに表示されているものを実行している#####
chsh -s /bin/zsh
# fzfの初期化
# Do you want to update your shell configuration files? はNoにする。
/usr/local/opt/fzf/install
######

# 初期化
nvm
tmux # [ctrl + I]でtmux pluginをインストール
vim # neovim関連のインストール
```

#### システム環境設定の変更2
- システム環境設定 > キーボード > 入力ソース
  - Googleのひらがなと英数を追加
  - Appleデフォルトの日本語ローマ字入力の入力モードの英字をチェックしてから日本語ローマ字入力とABCを削除して、PC再起動

### アプリの初期化と設定
```zsh
open -a hyperSwitch
open -a Raycast # Advanced > Import/Export
open -a BetterTouchTool
open -a karabiner-elements
cp ./.config/karabiner/karabiner.json ~/.config/karabiner/
```

#### itermの設定
- Preferences > Gerenal > Preferences
- `Load preferences from a custmom folder or URL`
  - ./iterm/を設定

### その他設定
```zsh
# githubの設定
gh auth login

# sshの設定
vim ~/.ssh/config
ssh-keygen -t rsa # ~/.ssh配下に作成する
```

## 環境特有の設定
- 以下の作成/変更
  - `~/.config/git/.gitconfig.local`
  - `~/.zsh/local.zsh`
  - `~/.vim/local.vim`
  - `~/.ssh/config`

## 各種言語の設定
### Node
```zsh
nvm ls-remote --lts # 最新のLTSを確認
nvm install [lts-ver] # 確認したLTS verをInstall
nvm alias default [lts-ver]
```

### Python
https://qiita.com/sigwyg/items/41630f8754c2028a7a9f
```zsh
VER_2=2.7.18
VER_3=3.10.5

# python2環境
pyenv install $VER_2
pyenv virtualenv $VER_2 neovim-2
pyenv activate neovim2
pip2 install neovim
pyenv which python

# python3環境
pyenv install $VER_3
pyenv virtualenv $VER_3 neovim-3
pyenv activate neovim3
pip install neovim
pyenv which python
```
## その他設定
[memo commandを使用するとき](https://mattn.kaoriya.net/software/memo.htm)
```zsh
go get github.com/mattn/memo
vim ./config/memo/config.toml # 設定変更する必要あり
```


