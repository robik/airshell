#!/bin/bash

ash_module_ssh()
{
    if [ -n "$SSH_CLIENT" ]; then
        ash_return_text "SSH"
    else
        ash_return_none
    fi
}

ash_module_user()
{
    ash_return_text "$(whoami)"
}

ash_module_host()
{
    ash_return_text "$(uname -n)"
}

ash_module_path()
{
    ash_return_text "$(pwd | sed -e "s/^\/home\/$(whoami)/~/")"
}

ash_module_user_char()
{
    if [ `id -u` -eq 0 ]; then
        ash_return_text "#"
    else
        ash_return_text "$"
    fi
}

ash_validate_module_git()
{
    if [[ $? && ! -x "$(which git)" ]]; then
        printf "\e[1;31mConfiguration Error\e[0m: Git command not found. Either install git or remove git module.\n"
        return $ASH_VALIDATION_FAILURE
    fi
    return $ASH_VALIDATION_SUCCESS
}

ash_module_git()
{   
    local res="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ "$res" != "" ]; then
        ash_return_text "$BRANCH_CHAR $res" `expr ${#res} + 2`
    else
        ash_return_none
    fi
}

ash_module_venv()
{
    [ -z "$VIRTUAL_ENV" ] && { ash_return_none; return; }
    
    ash_return_text "(env)"
}

ash_module_date()
{
    ash_return_text "$(date +'%H:%M:%S')"
}
