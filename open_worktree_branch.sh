#!/usr/bin/env bash
# worktree で checkout 済みのブランチを、メインの作業ディレクトリで開けるようにする。
#
# git は同じブランチを複数の worktree で同時に checkout できない
# (fatal: '<branch>' is already used by worktree ...) ため、Claude Code などが
# .claude/worktrees/ 配下に作った worktree のブランチをメインで開くには、
# 先に worktree 側のブランチを手放す必要がある。このスクリプトはそれを安全に行う:
#
#   1. ブランチを checkout している worktree を特定する
#   2. worktree 側を detached HEAD に切り替えてブランチを解放する
#      （worktree のファイルは同じコミット内容のまま残る）
#   3. メインの作業ディレクトリでそのブランチを checkout する
#
# worktree に未コミットの変更がある場合、デフォルトでは中断する。
# --move-changes を付けると stash 経由でメイン側へ変更を持ってくる。
# 共有 stash スタックで他セッションのエントリを誤って pop しないよう、
# 一意なタグを付けて SHA で apply / drop する（bare な stash pop は使わない）。
#
# 使い方（リポジトリ内の任意の場所から実行可。fish の open-worktree-branch 経由でも同じ）:
#   open_worktree_branch.sh <branch> [--move-changes] [--remove]
#
#   --move-changes  worktree の未コミット変更（未追跡ファイル含む）をメイン側へ移す
#   --remove        ブランチ解放後に worktree 自体を削除する
#                   （未コミット変更が残る場合は --move-changes も必要）

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <branch> [--move-changes] [--remove]" >&2
  exit 2
}

# SHA から現在の stash@{n} を引き直して drop する（他セッションの push で番号がずれるため）
drop_stash_by_sha() {
  local sha="$1" repo="$2" ref
  ref="$(git -C "$repo" stash list --format='%H %gd' \
    | awk -v sha="$sha" '$1 == sha { print $2; exit }')"
  [ -n "$ref" ] && git -C "$repo" stash drop --quiet "$ref"
}

BRANCH=""
MOVE_CHANGES=0
REMOVE_WORKTREE=0
for arg in "$@"; do
  case "$arg" in
    --move-changes) MOVE_CHANGES=1 ;;
    --remove) REMOVE_WORKTREE=1 ;;
    -h|--help) usage ;;
    -*) echo "unknown option: $arg" >&2; usage ;;
    *)
      [ -n "$BRANCH" ] && usage
      BRANCH="$arg"
      ;;
  esac
done
[ -n "$BRANCH" ] || usage

# メイン worktree のパス = 共通 .git ディレクトリの親。
# worktree の中から実行されても正しくメインを指す。
GIT_COMMON_DIR="$(git rev-parse --path-format=absolute --git-common-dir)"
MAIN_ROOT="$(dirname "$GIT_COMMON_DIR")"

git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH" || {
  echo "error: branch '$BRANCH' does not exist" >&2
  exit 1
}

# --porcelain 出力からブランチを checkout 中の worktree を探す
FOUND_WT=""
current_wt=""
while IFS= read -r line; do
  case "$line" in
    worktree\ *) current_wt="${line#worktree }" ;;
    branch\ refs/heads/"$BRANCH") FOUND_WT="$current_wt" ;;
  esac
done < <(git -C "$MAIN_ROOT" worktree list --porcelain)

if [ "$FOUND_WT" = "$MAIN_ROOT" ]; then
  echo "'$BRANCH' is already checked out in the main working directory: $MAIN_ROOT"
  exit 0
fi

STASH_SHA=""
if [ -n "$FOUND_WT" ]; then
  echo "branch '$BRANCH' is checked out in worktree: $FOUND_WT"

  if [ -n "$(git -C "$FOUND_WT" status --porcelain)" ]; then
    if [ "$MOVE_CHANGES" -ne 1 ]; then
      echo "error: worktree has uncommitted changes." >&2
      echo "  - commit them in the worktree first, or" >&2
      echo "  - rerun with --move-changes to carry them to the main directory" >&2
      exit 1
    fi
    STASH_TAG="open-worktree-branch:$BRANCH:$(date +%s):$$"
    echo "stashing uncommitted changes in worktree (tag: $STASH_TAG)"
    git -C "$FOUND_WT" stash push -u -m "$STASH_TAG" >/dev/null
    STASH_SHA="$(git -C "$FOUND_WT" stash list --format='%H %gs' \
      | awk -v tag="$STASH_TAG" 'index($0, tag) { print $1; exit }')"
    if [ -z "$STASH_SHA" ]; then
      echo "error: failed to locate the stash entry just created" >&2
      exit 1
    fi
  fi

  echo "detaching worktree HEAD to release the branch"
  git -C "$FOUND_WT" switch --detach --quiet
fi

echo "checking out '$BRANCH' in $MAIN_ROOT"
if ! git -C "$MAIN_ROOT" switch "$BRANCH"; then
  # checkout に失敗したら worktree を元のブランチに戻し、stash も復元する
  if [ -n "$FOUND_WT" ]; then
    echo "checkout failed; restoring worktree to '$BRANCH'" >&2
    git -C "$FOUND_WT" switch --quiet "$BRANCH"
    if [ -n "$STASH_SHA" ]; then
      git -C "$FOUND_WT" stash apply --quiet "$STASH_SHA" && drop_stash_by_sha "$STASH_SHA" "$FOUND_WT"
    fi
  fi
  exit 1
fi

if [ -n "$STASH_SHA" ]; then
  echo "applying stashed changes in $MAIN_ROOT"
  if git -C "$MAIN_ROOT" stash apply "$STASH_SHA"; then
    drop_stash_by_sha "$STASH_SHA" "$MAIN_ROOT"
  else
    echo "warning: stash apply failed (conflicts?). The stash entry is kept: $STASH_SHA" >&2
    echo "  resolve manually, then: git stash drop <the stash@{n} whose SHA matches>" >&2
    exit 1
  fi
fi

if [ "$REMOVE_WORKTREE" -eq 1 ] && [ -n "$FOUND_WT" ]; then
  echo "removing worktree: $FOUND_WT"
  git -C "$MAIN_ROOT" worktree remove "$FOUND_WT"
fi

echo "done: '$BRANCH' is now checked out in $MAIN_ROOT"
