# alias
alias rm='rm -i'
alias be='bundle exec'
alias refresh_db='be rails db:drop; be rails db:create; be rails db:apply; be rails db:seed'
set -g fish_user_paths "/usr/local/opt/libxml2/bin" $fish_user_paths
alias g='git'
alias clearcache='rm -fr ~/Library/Developer/Xcode/DerivedData/*; rm -fr ~/Library/Caches/org.carthage.CarthageKit/; rm -fr ~/Library/Caches/carthage/'
alias killapps='launchctl reboot aps'
alias dcm='docker compose'

function into
  docker compose exec $argv[1] sh
end

# PATH
set PATH $HOME/.nodebrew/current/bin $PATH
set PATH $HOME/Library/Android/sdk/platform-tools $PATH
set PATH $HOME/go/bin $PATH
set PATH /Applications/"Android Studio.app"/Contents/jre/jdk/Contents/Home/bin $PATH
set JAVA_HOME /Applications/"Android Studio.app"/Contents/jre/jdk/Contents/Home

set -U fish_prompt_pwd_dir_length 0

set -gx PKG_CONFIG_PATH "/usr/local/opt/libxml2/lib/pkgconfig"

function fish_user_key_bindings
  bind \cr peco_select_history
end

set -g fish_user_paths "/usr/local/opt/qt/bin" $fish_user_paths

if status is-interactive
    eval (/opt/homebrew/bin/brew shellenv) # <= これを追加
end
