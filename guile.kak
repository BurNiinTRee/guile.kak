declare-option -hidden str guile_socket
declare-option -hidden str guile_pid

define-command guile-start-repl %{
    evaluate-commands %sh{
        socket=$(mktemp -u)
        fifo=$(mktemp -u)
        mkfifo $fifo
        printf %s\\n "set-option global guile_socket $socket"
        ( guile -q --listen=$socket ) >/dev/null 2>&1 </dev/zero &
        printf %s\\n "set-option global guile_pid $!"
    }
    hook -once -group guile global BufClose guile guile-stop-repl
    edit guile
}

define-command guile-stop-repl %{
    evaluate-commands %sh{
        kill $kak_opt_guile_pid
        rm $kak_opt_guile_socket
        printf %s\\n "echo $kak_opt_guile_pid
        set-option global guile_pid ''
        set-option global guile_socket ''"
    }
}

define-command guile-evaluate -params 1 -docstring \
  "Evaluates the given string in the context of the current guile session" %{
    guile-write-to-buffer %sh{
        printf "$kak_selection\n" | socat - UNIX-CLIENT:$kak_opt_guile_socket | \
            tail +9 | sed 's/\$[0-9]* = \(.*\)/\1/g'
    }
}

define-command guile-write-to-buffer -params 1 %{
    execute-keys -buffer guile %sh{
        sanitized_input="$(echo $1 | sed 's/</<lt>/g')"
        printf "<esc>gjo%s<esc>" "$sanitized_input"
    }
}

define-command guile-evaluate-selection %{
    guile-evaluate %sh{
        printf "%s\n" "$kak_selection"
    }
}

define-command guile-load-buffer %{
    execute-keys -draft '%: guile-evaluate-selection<ret>'
}
