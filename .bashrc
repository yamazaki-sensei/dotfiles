export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls="ls -G"
alias rm="rm -i"
gvim() {
	local f
	for f; do
		test -e "$f" || touch "$f"
	done
	open -a MacVim "$@"
}

PATH="$PATH":/Applications/mi.app/Contents/MacOS
PATH="$PATH":/Applications/Sublime\ Text.app/Contents/SharedSupport/bin

export PATH=/usr/local/bin:$PATH
export GIT_EDITOR="/usr/bin/vim"

. ~/.nvm/nvm.sh
nvm use default
npm_dir=${NVM_PATH}_modules
export NODE_PATH=$npm_dir

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# alias jenkins="java -jar /usr/local/opt/jenkins/libexec/jenkins.war"

# The next line updates PATH for the Google Cloud SDK.
# source '/Users/hira/google-cloud-sdk/path.bash.inc'

# The next line enables bash completion for gcloud.
# source '/Users/hira/google-cloud-sdk/completion.bash.inc'

# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

# ssh to raspberry pi
alias ssh_rpi='ssh hira@192.168.10.11'

