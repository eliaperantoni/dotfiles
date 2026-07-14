function z
    set -l list_cmd "zellij ls -n 2>/dev/null | awk '{ name = \$0; sub(/ \\[Created .*/, \"\", name); icon = (index(\$0, \"(EXITED\") ? \"💤\" : \"🟢\"); print icon \" \" name }'"
    set -l output (eval $list_cmd | \
        fzf --print-query \
            --expect=ctrl-o \
            --tac \
            --prompt='session> ' \
            --delimiter ' ' \
            --nth 2.. \
            --header 'enter: attach  ^o: new  ^d: kill  ^x: delete' \
            --bind "ctrl-d:execute-silent(zellij kill-session -- {2..})+reload($list_cmd)" \
            --bind "ctrl-x:execute-silent(zellij delete-session --force -- {2..})+reload($list_cmd)")
    set -l session
    set -l selected

    if test "$output[2]" = ctrl-o
        set session "$output[1]"
    else
        if test -n "$output[3]"
            set selected "$output[3]"
        else if test -n "$output[2]"
            set selected "$output[2]"
        end

        if test -n "$selected"
            set session (string replace -r '^[^ ]+ ' '' -- "$selected")
        else
            set session "$output[1]"
        end
    end

    if test -n "$session"
        if set -q ZELLIJ
            zellij action switch-session -- "$session"
        else
            zellij attach -c -- "$session"
        end
    end
end
