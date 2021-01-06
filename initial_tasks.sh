/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew install fish
brew install git
brew install hub
brew install rbenv
brew install nodebrew
brew install peco
nodebrew install-binary latest
curl -L http://get.oh-my.fish | fish
omf install peco

sudo echo '/usr/local/bin/fish' >> /etc/shells
chsh -s /usr/local/bin/fish

npm install -g npmbrew
npm install -g avn avn-nvm avn-n
npm install -g avn-nodebrew
avn setup


