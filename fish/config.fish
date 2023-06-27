# alias
alias rm='rm -i'
alias be='bundle exec'
set -g fish_user_paths "/usr/local/opt/libxml2/bin" $fish_user_paths
alias g='git'
alias killapps='launchctl reboot aps'
alias dcm='docker compose'

function into
  docker compose exec $argv[1] sh
end

# PATH
set PATH $HOME/.nodebrew/current/bin $PATH

set -U fish_prompt_pwd_dir_length 0

set -gx PKG_CONFIG_PATH "/usr/local/opt/libxml2/lib/pkgconfig"

function fish_user_key_bindings
  bind \cr peco_select_history
end

set -g fish_user_paths "/usr/local/opt/qt/bin" $fish_user_paths

if status is-interactive
    eval (/opt/homebrew/bin/brew shellenv) # <= これを追加
end
