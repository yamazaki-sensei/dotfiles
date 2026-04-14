# dotfiles

Nix (nix-darwin + home-manager) で macOS の環境構築を宣言的に管理する dotfiles。

## 構成

```
flake.nix    # エントリポイント（nix-darwin + home-manager を統合）
darwin.nix   # macOS システム設定（fish の /etc/shells 登録など）
home.nix     # ユーザー設定（パッケージ、dotfiles シンボリックリンク、fish 設定）
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

### 依存を更新する

```bash
# すべての入力を最新に更新
nix flake update --flake ~/dotfiles

# 特定の入力だけ更新
nix flake update nixpkgs --flake ~/dotfiles

# 更新後に反映
darwin-rebuild switch --flake ~/dotfiles
```

## ファイルの役割

| ファイル | 役割 |
|---|---|
| `flake.nix` | nixpkgs, nix-darwin, home-manager の入力定義とシステム構成 |
| `darwin.nix` | macOS システムレベルの設定（fish シェル有効化、Nix 設定） |
| `home.nix` | ユーザーレベルの設定（パッケージ、dotfiles リンク、fish 設定） |
| `flake.lock` | 入力のバージョン固定（自動生成、コミットに含める） |

## 旧スクリプトとの対応

| 旧 | 新 (Nix) |
|---|---|
| `install.sh`（シンボリックリンク作成） | `home.file` in `home.nix` |
| `initial_tasks.sh`（brew install） | `home.packages` in `home.nix` |
| `initial_tasks.sh`（chsh / /etc/shells） | `programs.fish.enable` in `darwin.nix` |

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
