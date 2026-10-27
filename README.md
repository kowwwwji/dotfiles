# Dotfiles

kowwwwji's DotFile & PC setup

## 環境構築

### システム環境設定の変更1

トラックパッド・キーボード・ショートカット・メニューバー等の設定は
`init.sh` から呼ばれる `.scripts/macos-defaults` が行う。それ以外の手動設定:

1. メニューバーの表示
   - コントロールセンター > Bluetooth をメニューバーに表示

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

# machine ラベルを設定（仕事用PCは work、個人用PCは personal）。
export DOTFILES_HOST=work
echo "export DOTFILES_HOST=$DOTFILES_HOST" >> ~/.zsh/local.zsh

# 共通 + このPC固有をまとめて導入
cd Brewfile && ./brewInstall.sh

sudo shutdown -r now
```

#### システム環境設定の変更2

- システム環境設定 > キーボード > 入力ソース
  - Googleのひらがなと英数を追加
  - Appleデフォルトの日本語ローマ字入力の入力モードの英字をチェック
  - 日本語ローマ字入力とABCを削除

### アプリの初期化と設定

```sh
tmux # [ctrl+\ + I]でtmux pluginをインストール
nv # neovim関連のインストール

open -a Raycast # Advanced > Import/Export。さらに Settings > Extensions > Script Commands に ~/.scripts/raycast を登録
open -a BetterTouchTool
open -a karabiner-elements
```

### ウィンドウ管理（AeroSpace / JankyBorders / SketchyBar）

自動化できない macOS 側の GUI 操作（PC ごとに手動）:

1. AeroSpace.app を初回起動し、アクセシビリティ権限を許可する

> [!NOTE]
> SketchyBar のワークスペース表示はフォーカス変更イベントで更新されるため、
> フォーカスを変えずに裏のワークスペースへウィンドウを移した直後は、
> 次のフォーカス変更までバーに反映されない（既知の制約として許容）。

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

言語ランタイムと CLI ツールは `init.sh` が mise で導入する（`.tool-versions` と `.config/mise/config.toml`）。

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

### 手動インストール

- [DMM Books](https://book.dmm.com/info_bookviewer.html#intro-mac)
- [LuminarAI](https://skylum.com/jp/account/my-softwar://skylum.com/jp/account/my-software)
- [Imaging Edge Desktop](https://creatorscloud.sony.net/catalog/ja-jp/ie-desktop/index.html)
- [MOTU M Series System Preferences](https://motu.com/en-us/download/product/408/?details=true)
- [IK product manager](https://www.ikmultimedia.com/products/productmanager/)
