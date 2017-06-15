sudo /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install fish
brew install git
brew install hub
brew update
brew install rbenv
brew install nodebrew
nodebrew install-binary latest

npm install -g npmbrew

sudo pip install virtualenv
sudo pip install virtualenvwrapper
sudo pip install virtualfish

sudo echo '/usr/local/bin/fish' >> /etc/shells
chsh -s /usr/local/bin/fish

