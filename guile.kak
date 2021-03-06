declare-option -hidden str guile_socket
declare-option -hidden str guile_pid
declare-user-mode guile

hook -group guile global WinSetOption filetype=scheme %{
    map -docstring "Evaluates the current buffer" window guile l ": guile-load-buffer<ret>"
    map -docstring "Evaluates the current selection" window guile e ": guile-evaluate-selection<ret>"
    map -docstring "Restart the guile session" window guile r ": guile-stop-repl<ret>: guile-start-repl<ret>"
}

define-command guile-start-repl %{
    evaluate-commands %sh{
        socket=$(mktemp -u)
        printf %s\\n "set-option global guile_socket $socket"
        ( guile -q --listen=$socket -L .) >/dev/null 2>&1 </dev/zero &
        pid=$!
        printf %s\\n "set-option global guile_pid '$pid'
            hook -once -group guile global KakEnd .* 'guile-stop-repl $pid'"
    }
    edit -scratch guile
}

define-command -params 0..1 guile-stop-repl %{
    evaluate-commands %sh{
        if [[ -z $1 ]] ;then
            kill $kak_opt_guile_pid
        else
            kill $1
        fi
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
            tail +9 | sed 's/\$[0-9]* = \(.*\)/=> \1/g'
    }
}

define-command guile-write-to-buffer -params 1 %{
    evaluate-commands -buffer guile -save-regs '"' %{
        set-register '"' %arg(1)
        execute-keys 'gep'
    }
}

define-command guile-evaluate-selection %{
    guile-evaluate %val{selection}
}

define-command guile-load-buffer %{
    execute-keys -draft '%: guile-evaluate-selection<ret>'
}
