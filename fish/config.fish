eval (python -m virtualfish)

functions -c fish_prompt _old_fish_prompt
function fish_prompt
    if set -q VIRTUAL_ENV
        echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
    end
    _old_fish_prompt
end

alias rm='rm -i'
alias be='bundle exec'
alias refresh_db='be rails db:drop; be rails db:create; be rails db:apply; be rails db:seed'
