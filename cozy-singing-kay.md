# NixでDotfiles管理を実現する方法

## 現状のスクリプト

### initial_tasks.sh
- Homebrewインストール
- パッケージ: fish, git, gh, rbenv, peco, tig
- oh-my-fish + pecoプラグイン
- fishをデフォルトシェルに設定

### install.sh
- dotfilesのシンボリックリンク作成（.gitconfig, .vimrc, .tigrc など）

---

## Nixで実現する方法

### 推奨アプローチ: nix-darwin + home-manager

macOSでは **nix-darwin** と **home-manager** の組み合わせが最も一般的です。

#### 1. nix-darwin
- macOS専用のNix設定管理
- システムレベルの設定（デフォルトシェル変更など）
- Homebrewの代わりにパッケージをインストール

#### 2. home-manager
- ユーザー環境とdotfilesの宣言的管理
- シンボリックリンクの自動作成
- fish、git、vimなどのプログラム設定を直接Nixで記述可能

---

## 実装例

### ディレクトリ構造
```
dotfiles/
├── flake.nix           # メインエントリーポイント
├── darwin/
│   └── default.nix     # nix-darwin設定
└── home/
    └── default.nix     # home-manager設定
```

### flake.nix (例)
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."hostname" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # Apple Silicon
      modules = [
        ./darwin
        home-manager.darwinModules.home-manager
        {
          home-manager.users.hiraku = import ./home;
        }
      ];
    };
  };
}
```

### home/default.nix (例)
```nix
{ pkgs, ... }: {
  # パッケージのインストール (initial_tasks.shの代替)
  home.packages = with pkgs; [
    fish
    git
    gh
    rbenv
    peco
    tig
  ];

  # dotfilesのシンボリックリンク (install.shの代替)
  home.file = {
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".gitignore".source = ../dotfiles/.gitignore;
    ".vimrc".source = ../dotfiles/.vimrc;
    ".vim".source = ../dotfiles/.vim;
    ".tigrc".source = ../dotfiles/.tigrc;
    ".ideavimrc".source = ../dotfiles/.ideavimrc;
    ".xvimrc".source = ../dotfiles/.xvimrc;
    ".inputrc".source = ../dotfiles/.inputrc;
    ".gvimrc".source = ../dotfiles/.gvimrc;
    ".git_template".source = ../dotfiles/.git_template;
  };

  # fishの設定 (より宣言的な方法)
  programs.fish = {
    enable = true;
    plugins = [
      # oh-my-fishの代わりにfisher等を使うことが多い
    ];
  };

  # gitの設定 (dotfileの代わりに直接設定も可能)
  programs.git = {
    enable = true;
    # ... 設定をここに書くことも可能
  };
}
```

### darwin/default.nix (例)
```nix
{ pkgs, ... }: {
  # デフォルトシェルの変更
  programs.fish.enable = true;

  # Nixの設定
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

---

## メリット・デメリット

### メリット
- **宣言的**: 設定ファイル1つで環境を再現可能
- **再現性**: 別のマシンでも同じ環境を構築可能
- **ロールバック**: 問題があれば以前の状態に戻せる
- **バージョン管理**: パッケージのバージョンを固定可能

### デメリット
- **学習コスト**: Nix言語の習得が必要
- **複雑性**: 単純なシェルスクリプトより複雑
- **oh-my-fish**: Nixで直接管理しにくい（代替としてfisherを使うことが多い）

---

## 移行の選択肢

| 選択肢 | 説明 |
|--------|------|
| **A: フル移行** | 全てをNixで管理。最も宣言的だが学習コスト高 |
| **B: パッケージのみ** | パッケージ管理はNix、dotfilesは既存のまま |
| **C: ハイブリッド** | nix-darwin + 既存のinstall.sh併用 |

---

## 次のステップ

1. Nixをインストール（まだの場合）
2. flake.nixを作成
3. 段階的に設定を移行
