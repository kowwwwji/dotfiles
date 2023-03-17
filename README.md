# Dotfiles

kowwwwji's DotFile & PC setup

## 環境構築

### システム環境設定の変更1

1. トラックパッドの`軌跡の速さ`を最大に
1. キーボード
   - `キーのリピート`と`リピート入力認識までの時間`を最大に。
   - F1F2をファンクションキーとして使用にチェック
   - ショートカットのSpotlight検索を表示をOFF
1. 音声入力のショートカットを`Fn`に
1. メニューバーの表示
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

cd BrewFile && brew bundle # Application Install
# 以下はログに表示されているものを実行している#####
# fzfの初期化
$(brew --prefix)/opt/fzf/install # Do you want to update your shell configuration files? はNoにする。
###################################################
sudo shutdown -r now

```

#### システム環境設定の変更2

- システム環境設定 > キーボード > 入力ソース
  - Googleのひらがなと英数を追加
  - Appleデフォルトの日本語ローマ字入力の入力モードの英字をチェック
  - 日本語ローマ字入力とABCを削除

### Node

```zsh
nvm ls-remote --lts # 最新のLTSを確認
nvm install [lts-ver] # 確認したLTS verをInstall
nvm alias default [lts-ver]
```
### アプリの初期化と設定

```zsh
tmux # [ctrl + I]でtmux pluginをインストール
vim # neovim関連のインストール

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
    - `let g:github_enterprise_urls = ['https://example.com']`
  - `~/.ssh/config`

## 各種言語の設定
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

## その他

### [memo commandを使用するとき](https://mattn.kaoriya.net/software/memo.htm)

```zsh
go get github.com/mattn/memo
vim ./config/memo/config.toml # 設定変更する必要あり
```

### coc.nvimの設定

### 手動インストール

- [DMM Books](https://book.dmm.com/info_bookviewer.html#intro-mac)
- [LuminarAI](https://skylum.com/jp/account/my-softwar://skylum.com/jp/account/my-software)
- [Imaging Edge Desktop](https://creatorscloud.sony.net/catalog/ja-jp/ie-desktop/index.html)
- [MOTU M Series System Preferences](https://motu.com/en-us/download/product/408/?details=true)
