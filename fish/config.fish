# alias
alias rm='rm -i'
alias be='bundle exec'
alias refresh_db='be rails db:drop; be rails db:create; be rails db:apply; be rails db:seed'
set -g fish_user_paths "/usr/local/opt/libxml2/bin" $fish_user_paths
alias g='git'

# PATH
set PATH $HOME/.nodebrew/current/bin $PATH
set PATH $HOME/Library/Android/sdk/platform-tools $PATH

function cd
    if test (count $argv) -eq 0
        builtin cd
        return 0
    else if test (count $argv) -gt 1
        printf "%s\n" (_ "Too many args for cd command")
        return 1
    end
    # Avoid set completions.
    set -l previous $PWD

    if test "$argv" = "-"
        if test "$__fish_cd_direction" = "next"
            nextd
        else
            prevd
        end
        return $status
    end
    builtin cd $argv
    set -l cd_status $status
    # Log history
    if test $cd_status -eq 0 -a "$PWD" != "$previous"
        set -q dirprev[$MAX_DIR_HIST]
        and set -e dirprev[1]
        set -g dirprev $dirprev $previous
        set -e dirnext
        set -g __fish_cd_direction prev
    end

    if test $cd_status -ne 0
        return 1
    end
    sh $HOME/.avn/bin/avn.sh
    return $status
end

function fish_user_key_bindings
  bind \cr peco_select_history
end
