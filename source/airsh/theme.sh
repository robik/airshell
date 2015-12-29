airsh_theme_load() {
    local name="$1"; shift
    local location="$AIRSH_THEMES_DIR/$name.sh"

    if airsh_theme_is_loaded $name; then
        return
    fi

    if [ ! -f $location ]; then
        airsh_error "Theme '" $name "' cannot be found (is it installed?): '" $location "'"
        return
    fi

    name="${name//-/_}"
    AIRSH_THEMES_LOADED+=("$name")

    airsh_theme_dsl_install
    . $location
    if airsh_func_exists "airsh_theme_${name,,}__init"; then
        eval "airsh_theme_${name,,}__init"
    fi
    airsh_theme_dsl_uninstall
}

airsh_theme_is_loaded() {
    local name="$1"; shift

    airsh_array_has_element "$name" ${AIRSH_THEMES_LOADED[@]}
}


airsh_theme_get_var() {
    local array=false
    if [ "$1" = "-a" ]; then
        array=true
        shift
    fi

    local theme=${1^^}; shift
    local name="${1^^}"; shift
    theme=${theme//-/_}
    name=${name//-/_}

    { airsh_assert_name $name; } && return
    if $array; then
        name="$name[@]"
    fi

    echo "AIRSH_THEME_${theme}_${name}"
}

airsh_theme_get_prop() {
    local var="$(airsh_theme_get_var $@)"
    echo "${!var}"
}


airsh_theme_set_prop() {
    local var="$(airsh_theme_get_var $@)"
    eval "$var=\"$3\""
}

airsh_theme_set_style() {
    local var="$(airsh_theme_get_var $@)"
    eval "$var=\"$3\""
}


airsh_theme_get_conf() {
    local theme=${1^^}; shift
    local name="${1^^}"; shift

    echo `airsh_module_get_prop "$theme" "CONF_$name"`
}


airsh_theme_set_conf() {
    local theme=${1^^}; shift
    local name="${1^^}"; shift
    local value="${1}"; shift

    echo `airsh_module_set_prop "$theme" "CONF_$name" "$value"`
}

airsh_current_theme_get_prop() {
    if [ "$1" = "-a" ]; then
        shift
        airsh_theme_get_prop -a $AIRSH_CONF_THEME $@
    else
        airsh_theme_get_prop $AIRSH_CONF_THEME $@
    fi
}


airsh_current_theme_get_style() {
    local row_i=$1; shift
    local name="$1"; shift

    local style="$(airsh_current_theme_get_prop style_$name)"
    local default_bg="$(airsh_current_theme_get_prop row_{$row_id}_bg)"
    echo "${style//DEFAULT_BG/$default_bg}"
}
