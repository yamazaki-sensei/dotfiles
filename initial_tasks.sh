/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/hira/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew update
brew install fish
brew install git
brew install gh
brew install rbenv
brew install nodebrew
brew install peco
brew install tig
nodebrew install-binary latest
curl -L http://get.oh-my.fish | fish
omf install peco

sudo echo '/opt/homebrew/bin/fish' >> /etc/shells
chsh -s /opt/homebrew/bin/fish

