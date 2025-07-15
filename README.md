# Dotfiles

kowwwwji's DotFile & PC setup

## 環境構築

### システム環境設定の変更1

1. トラックパッド
   - `軌跡の速さ`を最大
   - １本指タップを有効
1. キーボード
   - `キーのリピート`と`リピート入力認識までの時間`を最大
   - F1F2をファンクションキーとして使用にチェック
   - ショートカットのSpotlight検索を表示をOFF
   - `次のウインドウを操作対象にする`のキーをOption+Tabに変更
1. 音声入力のショートカットを`Fn`に
1. メニューバーの表示
   - Dockとメニューバー
     - bluetooth ON
   - バッテリー ON
     - バッテリーの％表示
   - Spotlight OFF

### Various Installs

```bash
# Terminal
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.bash_profile

chsh -s /bin/bash; exec $SHELL -l
brew install ghq
# Access Tokenを作る必要あり
ghq get https://github.com/kowwwwji/dotfiles.git
cd $(ghq root)/github.com/kowwwwji/dotfiles

bash init.sh # $HOMEへの適用

chsh -s /bin/zsh
exit
```

```sh
# google imeで必要
softwareupdate --install-rosetta

cd $(ghq root)/github.com/kowwwwji/dotfiles
cd BrewFile && brew bundle # Application Install

sudo shutdown -r now
```

#### システム環境設定の変更2

- システム環境設定 > キーボード > 入力ソース
  - Googleのひらがなと英数を追加
  - Appleデフォルトの日本語ローマ字入力の入力モードの英字をチェック
  - 日本語ローマ字入力とABCを削除

#### iTermの設定

- Preferences > Gerenal > Preferences
- `Load preferences from a custmom folder or URL`
  - ./iterm/を設定
- Hotkeyが動かない場合は、PC再起動後に動くはず。

### アプリの初期化と設定

```sh
tmux # [ctrl+\ + I]でtmux pluginをインストール
nv # neovim関連のインストール

open -a Raycast # Advanced > Import/Export
open -a BetterTouchTool
open -a karabiner-elements
```

### その他設定

```sh
# githubの設定
gh auth login

# sshの設定
nv ~/.ssh/config
ssh-keygen -t rsa # ~/.ssh配下に作成する
```

## 環境特有の設定

- 以下の作成/変更
  - `~/.ssh/config`
  - `~/.config/git/.gitconfig.local`
  - `~/.zsh/local.zsh`
  - `~/.vim/local.vim` or `~/.config/nvim/lua/config/local.lua`
    - `let g:github_enterprise_urls = ['https://example.com']`

## 各種言語の設定

### Install asdf plugin & lang

```sh
ln -s ${DOTFILES_ROOT}.tool-versions ~/
cut -d' ' -f1 .tool-versions | xargs -I{} asdf plugin add {}
asdf list
asdf install
```

### Neovim Provider

```sh
# node
npm i -g neovim
# ruby
gem install neovim

# python
mkdir ~/.poetry
poetry new nv
cd nvim
poetry add Neovim

# in neovim  `:che provider`

```

## その他

```

### 手動インストール

- [DMM Books](https://book.dmm.com/info_bookviewer.html#intro-mac)
- [LuminarAI](https://skylum.com/jp/account/my-softwar://skylum.com/jp/account/my-software)
- [Imaging Edge Desktop](https://creatorscloud.sony.net/catalog/ja-jp/ie-desktop/index.html)
- [MOTU M Series System Preferences](https://motu.com/en-us/download/product/408/?details=true)
