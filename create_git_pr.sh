BRANCH=`git rev-parse --abbrev-ref HEAD`
TITLE="[$BRANCH]"
gh pr create --web --title $TITLE
