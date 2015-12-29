## Prints formatted message with colors
#
# Arguments:
#  main_ansi    ANSI code for main color (can be fg or bg)
#  alt_ansi     ANSI code for alternate color (can be fg or bg)
#  prefix       Message prefixed with main color
#  text...      Message parts
#
# This function swaps `main_ansi` with `alt_ansi` for every parameter (not every word though).
# That is every second parameter after `prefix` will be styled with `main_ansi` and others with `alt_ansi`.
# There is no space between `text`s.
_airsh_formatted_msg() {
    local main_color="$1"; shift
    local alt_color="$1"; shift
    local prefix="${1^^}"; shift
    local msg

    printf "${main_color}$prefix${AIRSH_ANSI_RESET} "

    local i=0
    for msg in "$@"; do
        if (( i % 2 == 0 )); then
            printf "${main_color}"
        else
            printf "${alt_color}"
        fi
        printf "$msg${AIRSH_ANSI_RESET}"

        ((i+=1))
    done

    printf "\n"
}


## Prints formatted error message
#
# Arguments:
#  text...      Message parts
#
# This function swaps bold red with red for every parameter (not every word).
airsh_error() {
    AIRSH_STATUS=$AIRSH_FAIL

    _airsh_formatted_msg "$AIRSH_FG_LIGHT_RED\e[24m" "$AIRSH_FG_LIGHT_RED\e[4m" "Error" "$@"
}


## Prints formatted warning message
#
# Arguments:
#  text...      Message parts
#
# This function swaps bold red with red for every parameter (not every word).
airsh_warn() {
    _airsh_formatted_msg $AIRSH_FG_YELLOW $AIRSH_FG_BROWN "Warning" "$@"
}


airsh_assert_name() {
    local key="$1"; shift
    local res
    [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]
    res=$?
    if [ $res -eq 0 ]; then
        airsh_warn "" "$key" " is not valid name"
    fi
    return $res
}


## Checks if function with specified name exists.
airsh_func_exists() {
    [ `type -t $1`"" == 'function' ]
}


airsh_func_get_source() {
    local name="$1"; shift

    echo "$(declare -f $name | tail -n +2)"
    #src=${src#*\{}
    #src=${src%\}}"$src"
}


## Checks if array contains an element.
airsh_array_has_element() {
    local element="$1"; shift
    local array="$@";

    case "$array" in
        *"$element"*)
            return 0
            ;;
        *)
            return 1
    esac
}
