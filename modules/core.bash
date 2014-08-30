#!/bin/bash

ash_register_module "ssh"
ash_register_module "user"
ash_register_module "host"
ash_register_module "path"
ash_register_module "user_char"
ash_register_module "git"
ash_register_module "venv"
ash_register_module "date"

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

ash_module_git()
{
    if [[ ! -x $(which git) ]]; then
        ash_return_none;
        return;
    fi
    
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
