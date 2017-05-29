eval (python -m virtualfish)

functions -c fish_prompt _old_fish_prompt
function fish_prompt
    if set -q VIRTUAL_ENV
        echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
    end
    _old_fish_prompt
end

