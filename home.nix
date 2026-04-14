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
    nodejs
    direnv
    mise
  ];

  # Dotfiles symlinks (replaces install.sh)
  home.file = {
    ".gitconfig".source = ./.gitconfig;
    ".gitignore".source = ./.gitignore;
    ".gvimrc".source = ./.gvimrc;
    ".ideavimrc".source = ./.ideavimrc;
    ".inputrc".source = ./.inputrc;
    ".vim".source = ./.vim;
    ".vimrc".source = ./.vimrc;
    ".xvimrc".source = ./.xvimrc;
    ".tigrc".source = ./.tigrc;
    "create_git_pr.sh".source = ./create_git_pr.sh;
    ".git_template".source = ./.git_template;
  };

  # Fish shell configuration
  # Using home.file instead of programs.fish to preserve existing config.fish as-is
  xdg.configFile."fish/config.fish".source = ./fish/config.fish;
  xdg.configFile."fish/completions".source = ./fish/completions;
  xdg.configFile."fish/conf.d".source = ./fish/conf.d;
  xdg.configFile."fish/functions".source = ./fish/functions;
  xdg.configFile."fish/fishfile".source = ./fish/fishfile;
  xdg.configFile."fish/fish_variables".source = ./fish/fish_variables;

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
