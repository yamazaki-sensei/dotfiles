# dotfiles

Nix (nix-darwin + home-manager) で macOS の環境構築を宣言的に管理する dotfiles。

## 構成

```
flake.nix    # エントリポイント（nix-darwin + home-manager を統合）
darwin.nix   # macOS システム設定（fish の /etc/shells 登録、homebrew cask など）
home.nix     # ユーザー設定（パッケージ、dotfiles シンボリックリンク、direnv / Karabiner）
karabiner/   # Karabiner-Elements の設定（karabiner.json と complex_modifications）
flake.lock   # 依存バージョンのロックファイル
```

## 前提条件

Nix がインストールされていること。未インストールの場合:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## セットアップ（初回）

```bash
# リポジトリをクローン
git clone <this-repo> ~/dotfiles
cd ~/dotfiles

# nix-darwin を初回ビルド・適用
nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake .
```

初回実行後は `darwin-rebuild` コマンドが使えるようになる。

## 設定の反映

Nix の設定ファイル（`home.nix`, `darwin.nix` など）を編集した後:

```bash
darwin-rebuild switch --flake ~/dotfiles
```

## よく使う操作

### パッケージを追加する

`home.nix` の `home.packages` にパッケージを追加して `darwin-rebuild switch` する。

```nix
# home.nix
home.packages = with pkgs; [
  fish
  git
  gh
  # ↓ 追加
  jq
  ripgrep
];
```

パッケージの検索:

```bash
nix search nixpkgs <パッケージ名>
```

### dotfile を追加する

`home.nix` の `home.file` にエントリを追加する。

```nix
home.file = {
  # 既存のエントリ...
  ".新しいファイル".source = ./新しいファイル;
};
```

`source = ./path` は nix store への read-only symlink になる。そのファイルを
**アプリや自分自身が書き換える**場合（vim が `~/.vim/.netrwhist` を書くなど）は
store に置けないので、working copy を指す out-of-store symlink にする。

```nix
".vim".source =
  config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/.vim";
```

### fish

fish の設定は home-manager 管理外。実体の `~/.config/fish/` が `dotfiles/fish/` から
大きく乖離しており、リンクすると現用の設定が `.backup` に退避されて古い内容に
置き換わってしまうため。`fish_variables` は fish 自身が実行時に書き込むファイルなので、
store symlink にすると `set -U` が壊れる点にも注意。

`dotfiles/fish/` を正本に戻すなら、まず実体を repo へ取り込んでから、
`fish_variables` を除いて `xdg.configFile` に載せ直すこと。

### direnv

`programs.direnv` で入れる。`nix-direnv.enable = true` は必須で、外してはいけない
（direnv 組み込みの `use_flake` はキャッシュを持たず、`cd` のたびに flake を再評価する）。
シェル統合は `fish/config.fish` の `direnv hook fish` が担当している。

### Karabiner-Elements

アプリ本体は `darwin.nix` の `homebrew.casks` で入れる。DriverKit のシステム機能拡張を含むため、nixpkgs 版（`services.karabiner-elements`）ではなく公式 pkg を使っている。

設定ファイルの扱いは 2 種類:

| パス | 方式 | 理由 |
|---|---|---|
| `~/.config/karabiner/karabiner.json` | repo への out-of-store symlink | GUI がこのファイルを書き換えるため、read-only な nix store は指せない。GUI で設定を変えるとそのまま `git diff` に出る |
| `~/.config/karabiner/assets/complex_modifications/` | store への symlink（`recursive = true`） | インポート済みルールは読み取り専用。ディレクトリ自体は実体なので GUI からの新規インポートも可能 |

つまり **GUI で設定を変えたらそのまま commit すればよい**。逆に repo 側の `karabiner/karabiner.json` を直接編集した場合は、Karabiner が変更を検知して即座に反映する。

新しいマシンでは `darwin-rebuild switch` の後、システム設定で以下の許可が必要:

- 「プライバシーとセキュリティ」→ 入力監視 → Karabiner-Elements
- 「一般」→ ログイン項目と機能拡張 → ドライバ機能拡張 → Karabiner-VirtualHIDDevice

もし Karabiner が symlink を実ファイルで置き換えてしまう挙動を見せたら（`ls -l ~/.config/karabiner/karabiner.json` で確認）、`home.nix` の `mkOutOfStoreSymlink` をやめて `home.activation` でのコピー方式に切り替える。

### 依存を更新する

```bash
# すべての入力を最新に更新
nix flake update --flake ~/dotfiles

# 特定の入力だけ更新
nix flake update nixpkgs --flake ~/dotfiles

# 更新後に反映
darwin-rebuild switch --flake ~/dotfiles
```

## コマンド

### open-worktree-branch — worktree が掴んでいるブランチをメインで開く

git は同じブランチを複数の worktree で同時に checkout できないので、Claude Code などが
`.claude/worktrees/` に作った worktree のブランチをメインの作業ディレクトリで開こうとすると
`fatal: '<branch>' is already used by worktree at ...` で失敗する。
worktree 側を detached HEAD にしてブランチを解放してから、メインで checkout し直す。

実体は `open_worktree_branch.sh`。3 通りの呼び方がある:

```bash
git owb <branch>                 # git alias（どのシェルからでも使える）
open-worktree-branch <branch>    # fish 関数
bash ~/dotfiles/open_worktree_branch.sh <branch>
```

fish は home-manager 管理外で、PATH も環境によって当てにならないので、
シェル非依存な git alias を正とする。fish 関数は打ち慣れた名前のために残してある。

| オプション | 挙動 |
|---|---|
| （なし） | worktree を detach するだけ。ディレクトリと未コミット変更はそのまま残る |
| `--move-changes` | worktree の未コミット変更（未追跡含む）を stash 経由でメイン側へ移す |
| `--remove` | ブランチ解放後に worktree 自体を削除する |

引数なしで実行すると、worktree が掴んでいるブランチの一覧が出る。

```bash
git owb
```

未コミット変更がある worktree は、`--move-changes` を付けない限り中断する。
stash スタックは worktree 間で共有されるため、一意なタグを付けて SHA で apply / drop している
（他セッションのエントリを誤って pop しないよう、bare な `git stash pop` は使わない）。
メインでの checkout に失敗した場合は worktree のブランチと stash を復元してから終了する。

`--remove` は、実行しているシェルの足元の worktree を消そうとした場合は中断する。

## ファイルの役割

| ファイル | 役割 |
|---|---|
| `flake.nix` | nixpkgs, nix-darwin, home-manager の入力定義とシステム構成 |
| `darwin.nix` | macOS システムレベルの設定（fish シェル有効化、Nix 設定、homebrew cask） |
| `home.nix` | ユーザーレベルの設定（パッケージ、dotfiles リンク、direnv / Karabiner 設定） |
| `karabiner/` | Karabiner-Elements の設定実体（`~/.config/karabiner` からリンクされる） |
| `open_worktree_branch.sh` | worktree が掴んでいるブランチをメインで開く（`git owb` / `open-worktree-branch`） |
| `flake.lock` | 入力のバージョン固定（自動生成、コミットに含める） |

## 旧スクリプトとの対応

| 旧 | 新 (Nix) |
|---|---|
| `install.sh`（シンボリックリンク作成） | `home.file` in `home.nix` |
| `initial_tasks.sh`（brew install） | `home.packages` in `home.nix` |
| `initial_tasks.sh`（chsh / /etc/shells） | `programs.fish.enable` in `darwin.nix` |
| `initial_tasks.sh`（brew cask） | `homebrew.casks` in `darwin.nix` |

## トラブルシューティング

### `darwin-rebuild` が見つからない

初回は `nix run` 経由で実行する必要がある:

```bash
nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ~/dotfiles
```

### flake.nix の変更が反映されない

新規ファイルは `git add` しないと Nix から見えない:

```bash
git add -N 新しいファイル
darwin-rebuild switch --flake ~/dotfiles
```

### 前の世代に戻したい

```bash
# 世代一覧を確認
darwin-rebuild --list-generations

# 一つ前に戻す
darwin-rebuild switch --rollback
```
