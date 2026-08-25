{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  # Packages (replaces `brew install` in initial_tasks.sh)
  home.packages = with pkgs; [
    fish
    git
    gh
    rbenv
    tig
    fzf
    ghq
    nodejs_24
    mise
  ];

  # Dotfiles symlinks (replaces install.sh)
  home.file = {
    ".gitconfig".source = ./.gitconfig;
    ".gitignore".source = ./.gitignore;
    ".gvimrc".source = ./.gvimrc;
    ".ideavimrc".source = ./.ideavimrc;
    ".inputrc".source = ./.inputrc;
    # vim は ~/.vim 配下に .netrwhist を書き込む (bundle/ も pathogen 管理) ので、
    # read-only な nix store には置けない。karabiner.json と同じく working copy を指す。
    ".vim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/.vim";
    ".vimrc".source = ./.vimrc;
    ".xvimrc".source = ./.xvimrc;
    ".tigrc".source = ./.tigrc;
    "create_git_pr.sh".source = ./create_git_pr.sh;
    ".git_template".source = ./.git_template;
  };

  # direnv は必ず nix-direnv と併用する。
  # direnv 本体の組み込み use_flake はキャッシュを持たず、cd のたびに
  # nix print-dev-env を実行する (teachme_web_duvel の flake で実測 4.5s +
  # 7,000 ファイルの store へのコピー + `removing profile version N`)。
  # nix-direnv は評価結果を .direnv/*.rc に保存し、flake.nix / flake.lock が
  # 変わったときだけ再評価するので、2 回目以降は数十 ms で済む。
  #
  # シェル統合は fish/config.fish の `direnv hook fish` が担っている
  # (programs.fish は使っていないので HM 側の integration は書き出されない)。
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Fish shell configuration は HM 管理外。
  # 実体の ~/.config/fish/ は dotfiles/fish/ から大きく乖離しており (functions は
  # prompt のみ / conf.d は空 / completions はツール生成)、リンクすると現用の設定が
  # .backup へ退避されて古い内容に置き換わる。fish_variables に至っては fish が実行時に
  # 書き込むファイルなので、read-only な store symlink にすると `set -U` が壊れる。
  # dotfiles/fish/ を正本に戻すなら、まず実体を dotfiles へ取り込んでから
  # fish_variables を除いて再度 xdg.configFile に載せること。

  # Karabiner-Elements
  # karabiner.json is rewritten by the Karabiner GUI itself, so it can't point
  # at the read-only nix store. Symlink to the working copy in this repo
  # instead: GUI edits land straight in `git diff`.
  xdg.configFile."karabiner/karabiner.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/karabiner/karabiner.json";
  # Imported rule presets are read-only inputs. `recursive` keeps the directory
  # itself writable so new imports from the GUI still work.
  xdg.configFile."karabiner/assets/complex_modifications" = {
    source = ./karabiner/assets/complex_modifications;
    recursive = true;
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
