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

### 新規マシンでのインストール（chezmoi使用）

**ワンライナーインストール:**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kowwwwji/dotfiles
```

初回実行時に以下の情報の入力を求められます:
- Full Name: (あなたの氏名)
- Email: (Gitで使用するメールアドレス)
- GPG Signing Key (optional): (GPG署名鍵、オプション)

**age暗号化鍵の復元:**

SSH鍵などの暗号化ファイルにアクセスするには、age鍵が必要です:

```bash
# パスワードマネージャーまたは別マシンから鍵を復元
mkdir -p ~/.config/age
# 鍵ファイルをコピー

# 再適用
chezmoi apply
```

**手動セットアップが必要な項目:**

```sh
# Google IMEで必要
softwareupdate --install-rosetta

# シェルをzshに変更
chsh -s /bin/zsh
exit

# 再起動
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

chezmoiのテンプレート機能により、マシン固有の設定は初回セットアップ時のプロンプトで自動的に設定されます。

追加の環境変数が必要な場合は、以下のファイルを編集してください:
- `~/.zsh/local.zsh` - 環境変数やPATH設定
- `~/.vim/local.vim` or `~/.config/nvim/lua/config/local.lua` - エディタ固有の設定
  - 例: `let g:github_enterprise_urls = ['https://example.com']`

設定を変更した場合は、chezmoiで管理:
```bash
chezmoi edit ~/.zsh/local.zsh
chezmoi apply
```

## 各種言語の設定

### Install asdf plugin & lang

asdfプラグインと言語バージョンは、chezmoiの初回セットアップ時に自動的にインストールされます（`run_once_after_02-asdf.sh.tmpl`により実行）。

手動で再インストールする場合:
```sh
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

### 手動インストール

- [DMM Books](https://book.dmm.com/info_bookviewer.html#intro-mac)
- [LuminarAI](https://skylum.com/jp/account/my-softwar://skylum.com/jp/account/my-software)
- [Imaging Edge Desktop](https://creatorscloud.sony.net/catalog/ja-jp/ie-desktop/index.html)
- [MOTU M Series System Preferences](https://motu.com/en-us/download/product/408/?details=true)
- [IK product manager](https://www.ikmultimedia.com/products/productmanager/)
