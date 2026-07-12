function z
    set -l list_cmd "zellij ls -n 2>/dev/null | awk '{ if (/EXITED/) print \"💤 \" \$1; else print \"🟢 \" \$1 }'"
    set -l session (eval $list_cmd | \
        fzf --print-query \
            --tac \
            --prompt='session> ' \
            --delimiter ' ' \
            --nth 2.. \
            --header 'enter: attach  ^o: new  ^d: kill  ^x: delete' \
            --bind 'ctrl-o:print-query' \
            --bind "ctrl-d:execute-silent(zellij kill-session {2..})+reload($list_cmd)" \
            --bind "ctrl-x:execute-silent(zellij delete-session --force {2..})+reload($list_cmd)" | \
        tail -1 | cut -d' ' -f2-)
    if test -n "$session"
        zellij attach -c $session
    end
end
