#!/bin/bash

## Airshell - Powerline/Airline inspired Bash prompt
# Copyright 2014 Robert Pasiński
# Licensed under MIT License
#
# https://github.com/robik/airshell

# If not interactive, skip
[ -z "$PS1" ] && return

# Load original bashrc
if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
fi

ash_check_powerline_symbols()
{
    local found_font=0
    local dirs=( "$HOME/.fonts" "/usr/share/fonts/X11/misc" )
    for font_dir in "${dirs[@]}"; do
        if [ -d "$font_dir" ]; then
            if [ -f "$font_dir/PowerlineSymbols.otf" ]; then
                found_font=1
                break;
            fi
        fi
    done
    
    if [[ ! -f "$HOME/.config/airshell/ignore-symbols-question" && $found_font -eq 0 ]]; then
        local answer=""
        printf "\e[1;33mWarning\e[0m: Powerline symbols have not been found!\n"
        printf "Those symbols are not required, however you may see weird characters command prompt. "
        printf "If you don't want to install them, you can change Airshell configuration to use different "
        printf "characters (LEFT_ARR and RIGHT_ARR variables).\n"
        printf "Do want to install Powerline Symbols? \e[1m[Y]es \e[0m[n]o [i]gnore: "
        read answer
        
        case "$answer" in
            'n'|'N')
                ;;
                
            'i'|'I')
                mkdir -p "$HOME/.config/airshell"
                touch "$HOME/.config/airshell/ignore-symbols-question"
                echo "Ignored!"
                ;;
                
            *)
                ash_install_powerline_symbols
                ;;
        esac
    fi
}  

ash_install_powerline_symbols()
{
    echo "Downloading..."
    pushd /tmp
    mkdir -p $HOME/.fonts
    mkdir -p $HOME/.config/fontconfig/conf.d/
    # As specified in https://powerline.readthedocs.org/en/latest/installation/linux.html#font-installation
    [ ! -f "PowerlineSymbols.otf" ] && wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    [ ! -f "10-powerline-symbols.conf" ] && wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mv PowerlineSymbols.otf $HOME/.fonts/
    mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
    popd
    echo "Updating font cache"
    sudo fc-cache -vf ~/.fonts/
    
    if [ $? ]; then
        echo "Success! If you still can't see symbols, try rebooting to apply the changes."
    else
        echo "Error while updating fontconfig cache"
    fi
}

ash_check_powerline_symbols

# Copies module colors from $1 to $2
ash_copy_module_colors()
{
    local source="$1"; shift
    local target="$1"; shift
    
    eval "MODULE_${target^^}_BG=\"\$MODULE_${source^^}_BG\""
    eval "MODULE_${target^^}_FG=\"\$MODULE_${source^^}_FG\""
}

# Arrays delimeting components in header bar
LEFT_ARR="" #"\ue0b2"
RIGHT_ARR="\ue0b0"
BRANCH_CHAR="\ue0a0"

LEFT_MODULES=(ssh user path)
RIGHT_MODULES=(git venv date)
PS1_MODULE="user_char"
PS2_CHAR="~"
COLOR_HEADER_BG="5;234"

THEME_MAIN_COLOR="5;31" # Light Blue
THEME_MAIN_CONTRAST="5;231" # White

MODULE_BASE_FG="38;$THEME_MAIN_CONTRAST"
MODULE_BASE_BG="5;234"

MODULE_USER_FG="1;38;$THEME_MAIN_CONTRAST" #"38;5;112"
MODULE_USER_BG="$THEME_MAIN_COLOR" # 237

MODULE_USER_CHAR_FG="38;$THEME_MAIN_COLOR"

MODULE_HOST_FG="1;37"
MODULE_HOST_BG="5;31" # 10

MODULE_PATH_FG="38;5;243"
MODULE_PATH_BG="5;234"

MODULE_GIT_FG="38;5;231"
MODULE_GIT_BG="5;130"

MODULE_DATE_FG="38;5;7"
MODULE_DATE_BG="5;237"

MODULE_VENV_FG="37"
MODULE_VENV_BG="5;22"

MODULE_SSH_FG="37"
MODULE_SSH_BG="5;3" # 3

MODULE_DATE_FG="37"
MODULE_DATE_BG="5;236"


TERM_RESET="\e[0m"

if [ -f ~/.config/airshell/theme ]; then
    source ~/.config/airshell/theme
fi

echo ${LEFT_MODULES[@]} ${RIGHT_MODULES[@]} | grep -q git
if [[ $? && ! -x "$(which git)" ]]; then
    printf "\e[1;31mConfiguration Error\e[0m: Git command not found. Either install git or remove git module.\n"
fi

# Used for restoring
ORIGINAL_PS1="$PS1"
ORIGINAL_PS2="$PS2"

################################################################ MODULES

ash_return_text()
{
    MODULE_RESULT="$1"; shift
    
    if [ $# -lt 1 ]; then
        MODULE_LENGTH="${#MODULE_RESULT}"
    else
        MODULE_LENGTH="$1"
    fi
}

ash_return_none()
{
    MODULE_RESULT=""
    MODULE_LENGTH="-1"
}

ash_mod_prop()
{
    local module=${1^^}; shift
    local type="$1"; shift
    local var="MODULE_${module}_${type}"
    eval "local data=\$$var"
    
    if [ -z "$data" ]; then
        eval "echo \$MODULE_BASE_${type}"
    else
        echo "$data"
    fi
}

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

# Fills row with spaced with specified color.
ash_fill_row()
{
    local cols=$(tput cols)
    
    printf "\e[48;${1}m" # Header BG
    for ((i=0;i<$cols;i++)); do
        printf " "
    done
    printf "\e[199D"
}

ash_build_left_side()
{
    local modules=()
    local modules_len=0
    local modules_i=1
    
    # Filter out empty modules
    for ((i=0;i<${#LEFT_MODULES[@]};i++)); do
        local module="${LEFT_MODULES[$i]}"
        eval "ash_module_$module"
        
        [ "$MODULE_RESULT" = "" ] && continue
        modules+=("$module")
        ((modules_len++))
    done
    
    # Display filtered modules
    for module in "${modules[@]}"; do
        eval "ash_module_$module"
        printf "\e[%s;48;%sm" $(ash_mod_prop $module FG) $(ash_mod_prop $module BG)
        printf " $MODULE_RESULT \e[0m"
        
        if [ $modules_i -lt $modules_len ]; then
            local next_module="${modules[$modules_i]}"
            printf "\e[38;%s;48;%sm$RIGHT_ARR" $(ash_mod_prop $module BG) $(ash_mod_prop $next_module BG)
        fi
        ((modules_i++))
    done
}

ash_build_right_side()
{
    local modules=()
    local modules_len=0
    local modules_i=1
    
    # Goto end of the line
    printf "\e[299C"
    
    # Filter out empty modules
    for ((i=${#RIGHT_MODULES[@]}-1;i>=0;i--)); do
        local module="${RIGHT_MODULES[$i]}"
        eval "ash_module_$module"
        
        [ "$MODULE_RESULT" = "" ] && continue
        modules+=("$module")
        ((modules_len++))
    done
    
    for module in "${modules[@]}"; do
        eval "ash_module_$module"
        
        if [ "$LEFT_ARR" != "" ]; then
            ((MODULE_LENGTH+=2))
            printf "\e[${MODULE_LENGTH}D"
            
            if [ $modules_i -lt $modules_len ]; then
                local next_module="${modules[$modules_i]}"
                printf "\e[38;%s;48;%sm$LEFT_ARR" $(ash_mod_prop $module BG) $(ash_mod_prop $next_module BG)
            else
                printf "\e[38;%s;48;%sm$LEFT_ARR" $(ash_mod_prop $module BG) $COLOR_HEADER_BG
            fi
        else
            ((MODULE_LENGTH+=1))
            printf "\e[${MODULE_LENGTH}D"
        fi
        ((modules_i+=1))
        printf "\e[%s;48;%sm" $(ash_mod_prop $module FG) $(ash_mod_prop $module BG)
        printf " $MODULE_RESULT "
        ((MODULE_LENGTH+=2))
        printf "\e[${MODULE_LENGTH}D"
    done
    
    printf "\e[299C\e[0m\n"
}

ash_build_top_bar()
{   
    printf "$(ash_fill_row $COLOR_HEADER_BG)"
    
    # Build list of non-empty modules
    ash_build_left_side
    ash_build_right_side
}

ash_print_module()
{
    eval "ash_module_$1"
    echo "$MODULE_RESULT"
}

ash_build_ps1()
{
    printf "\[$TERM_RESET\]\n"
    echo "\[\$(ash_build_top_bar)\]"
    
    local module="$PS1_MODULE"
    printf "\[\e[48;%s;%sm\] \$(ash_print_module $module) " "\$(ash_mod_prop $module BG)" "\$(ash_mod_prop $module FG)"
    printf "\[\e[0;38;%sm\]$RIGHT_ARR \[$TERM_RESET\]" $(ash_mod_prop $module BG)
}

ash_build_ps2()
{
    local module="$PS1_MODULE"
    printf "\[\e[48;%s;%sm\] \$PS2_CHAR " $(ash_mod_prop $module BG) $(ash_mod_prop $module FG)
    printf "\[\e[0;38;%sm\]$RIGHT_ARR \[$TERM_RESET\]" $(ash_mod_prop $module BG)
}


##################################################################### USER FUNCTIONS
disable_airshell()
{
    PS1="$ORIGINAL_PS1"
    PS2="$ORIGINAL_PS2"
}

enable_airshell()
{
    PS1="$AIRSHELL_PS1"
    PS2="$AIRSHELL_PS2"
}

AIRSHELL_PS1="$(ash_build_ps1)"
AIRSHELL_PS2="$(ash_build_ps2)"

enable_airshell
