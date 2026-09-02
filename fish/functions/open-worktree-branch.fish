# worktree で checkout 済みのブランチをメインの作業ディレクトリで開く。
# 実体は dotfiles/open_worktree_branch.sh（bash）。
# ~/.config/fish/functions/open-worktree-branch.fish からこのファイルへ symlink して使う
# （fish 設定は home-manager 管理外のため。home.nix のコメント参照）。
function open-worktree-branch --description "worktree で checkout 済みのブランチをメインの作業ディレクトリで開く"
    bash ~/dotfiles/open_worktree_branch.sh $argv
end
