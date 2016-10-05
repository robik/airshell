#!/bin/bash

## Airshell - Powerline/Airline inspired Bash prompt
# Copyright 2014 Robert Pasiński
# Licensed under MIT License
#
# https://github.com/robik/airshell

# Airshell prefix without trailing slash
if [ -z "$ASH_PREFIX" ]; then
    if [ -d "$HOME/.config/airshell" ]; then
        ASH_PREFIX="$HOME/.config/airshell"
    else
        ASH_PREFIX="."
    fi
fi

    
# If not interactive, skip
[ -z "$PS1" ] && return

# Load original bashrc
if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
fi

# Copies module colors from $1 to $2
ash_copy_module_colors()
{
    local source="$1"; shift
    local target="$1"; shift
    
    eval "MODULE_${target^^}_BG=\"\$MODULE_${source^^}_BG\""
    eval "MODULE_${target^^}_FG=\"\$MODULE_${source^^}_FG\""
}

# Arrays delimeting components in header bar
RIGHT_MODULE_DELIM="" #"\ue0b2"
LEFT_MODULE_DELIM="\ue0b0"
BRANCH_CHAR="\ue0a0"

LEFT_MODULES=(ssh user path)
RIGHT_MODULES=(git venv date)
IGNORED_MODULES=()
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

if [ -f $ASH_PREFIX/theme ]; then
    source $ASH_PREFIX/theme
fi

# Include external modules
if [ -d $ASH_PREFIX/modules ]; then
    for file in $(ls $ASH_PREFIX/modules | egrep '\.(ba)?sh$'); do
        source "$ASH_PREFIX/modules/$file"
    done
fi

REGISTERED_MODULES=( $(declare -F | awk -e '/ash_module_/ { print substr($3, 12); }') )
ASH_VALIDATION_SUCCESS=0
ASH_VALIDATION_FAILURE=1
# Validate module list
for module in ${LEFT_MODULES[@]} ${RIGHT_MODULES[@]}; do
    echo "${REGISTERED_MODULES[@]}" | grep -q "$module"
    if [[ $? -eq 0 ]]; then
        if [ "$(type -t ash_validate_module_$module)" = "function" ]; then
            eval "ash_validate_module_$module"
            
            if [ $? -eq $ASH_VALIDATION_FAILURE ]; then
                IGNORED_MODULES+=("$module")
            fi
        fi
    else
        printf "\e[1;31mError\e[0m: Unknown module '$module' is used\n"
    fi
done

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

# Fills row with spaced with specified color.
ash_fill_row()
{
    local cols=$(tput cols)
    
    printf "\e[48;${1}m" # Header BG
    for ((i=0;i<$cols;i++)); do
        printf " "
    done
    printf "\e[%sD" $cols
}

ash_build_left_side()
{
    local modules=()
    local modules_len=0
    local modules_i=1
    local module_results=()
    
    # Filter out empty modules
    for ((i=0;i<${#LEFT_MODULES[@]};i++)); do
        local module="${LEFT_MODULES[$i]}"
        
        echo ${IGNORED_MODULES[@]} | grep -q $module
        [ $? -eq 0 ] && continue
        
        eval "ash_module_$module"
        
        [ "$MODULE_LENGTH" = "-1" ] && continue
        module_results+=("$MODULE_RESULT")
        modules+=("$module")
        ((modules_len++))
    done
    
    modules_i=0
    # Display filtered modules
    for module in "${modules[@]}"; do
        #echo ">> ${module_results[$modules_i]}"
        printf "\e[%s;48;%sm" $(ash_mod_prop $module FG) $(ash_mod_prop $module BG)
        printf " ${module_results[$modules_i]} \e[0m"
        
        if [ $modules_i -lt `expr $modules_len - 1` ]; then
            local next_module="${modules[$modules_i+1]}"
            printf "\e[38;%s;48;%sm$LEFT_MODULE_DELIM" $(ash_mod_prop $module BG) $(ash_mod_prop $next_module BG)
        fi
        ((modules_i++))
    done
}

ash_build_right_side()
{
    local modules=()
    local modules_len=0
    local modules_i=1
    local module_results=()
    local module_lengths=()
    
    # Goto end of the line
    printf "\e[299C"
    
    # Filter out empty modules
    for ((i=${#RIGHT_MODULES[@]}-1;i>=0;i--)); do
        local module="${RIGHT_MODULES[$i]}"
        
        echo ${IGNORED_MODULES[@]} | grep -q $module
        [ $? -eq 0 ] && continue
        
        eval "ash_module_$module"
        
        [ "$MODULE_LENGTH" = "-1" ] && continue
        module_results+=("$MODULE_RESULT")
        module_lengths+=("$MODULE_LENGTH")
        modules+=("$module")
        ((modules_len++))
    done
    
    modules_i=0
    for module in "${modules[@]}"; do
        local module_length="${module_lengths[$modules_i]}"
        
        if [ "$RIGHT_MODULE_DELIM" != "" ]; then
            ((module_length+=2))
            printf "\e[${module_length}D"
            
            if [ $modules_i -lt `expr $modules_len - 1` ]; then
                local next_module="${modules[$modules_i-1]}"
                printf "\e[38;%s;48;%sm$RIGHT_MODULE_DELIM" $(ash_mod_prop $module BG) $(ash_mod_prop $next_module BG)
            else
                printf "\e[38;%s;48;%sm$RIGHT_MODULE_DELIM" $(ash_mod_prop $module BG) $COLOR_HEADER_BG
            fi
        else
            ((module_length+=1))
            printf "\e[${module_length}D"
        fi
        printf "\e[%s;48;%sm" $(ash_mod_prop $module FG) $(ash_mod_prop $module BG)
        printf " ${module_results[$modules_i]} "
        ((module_length+=2))
        printf "\e[${module_length}D"
        ((modules_i+=1))
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
    printf "\[\e[0;38;%sm\]$LEFT_MODULE_DELIM \[$TERM_RESET\]" $(ash_mod_prop $module BG)
}

ash_build_ps2()
{
    local module="$PS1_MODULE"
    printf "\[\e[48;%s;%sm\] \$PS2_CHAR " $(ash_mod_prop $module BG) $(ash_mod_prop $module FG)
    printf "\[\e[0;38;%sm\]$LEFT_MODULE_DELIM \[$TERM_RESET\]" $(ash_mod_prop $module BG)
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
