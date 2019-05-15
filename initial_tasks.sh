#sudo /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

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

npm install -g npmbrew

#sudo pip install virtualenv
#sudo pip install virtualenvwrapper
#sudo pip install virtualfish

sudo echo '/usr/local/bin/fish' >> /etc/shells
chsh -s /usr/local/bin/fish

