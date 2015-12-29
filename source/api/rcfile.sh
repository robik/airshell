% set rc_dsl = {}

% do rc_dsl.update({'load-theme': 'airsh_rc_load_theme'})
airsh_rc_load_theme() {
    local theme="$1"; shift

    airsh_theme_load $theme
}

% do rc_dsl.update({'load-module': 'airsh_rc_load_modules'})
airsh_rc_load_modules() {
    local module

    for module in $@; do
        airsh_module_load $module
    done
}


% do rc_dsl.update({'load-all-modules': 'airsh_rc_load_all_modules'})
airsh_rc_load_all_modules() {
    for filename in $AIRSH_MODULES_DIR/*.sh; do
        airsh_rc_load_modules `basename "${filename%%.*}"`
    done
}


% do rc_dsl.update({'prefix': 'airsh_rc_prefix'})
airsh_rc_prefix() {
    local component
    [ "$1" == "[" ] && shift

    for component in $@; do
        component=${component//-/_}
        [ "$component" == "]" ] && break
        airsh_component_check $component
        AIRSH_PREFIX_COMPONENTS+=("$component")
    done
}


% do rc_dsl.update({'row': 'airsh_rc_row'})
airsh_rc_row() {
    eval "AIRSH_ROW_${AIRSH_ROW_COUNT}_LEFT=()"
    eval "AIRSH_ROW_${AIRSH_ROW_COUNT}_RIGHT=()"

    if [ "$1" != "[" ]; then
        airsh_error "row must start with ["
        return
    fi
    shift
    local component

    while [ $# -gt 0 ]; do
        component="${1//-/_}"; shift

        [ "$component" == "]" ] && break
        airsh_component_check "$component"
        eval "AIRSH_ROW_${AIRSH_ROW_COUNT}_LEFT+=\"$component \""
    done

    if [ $# -lt 1 ]; then
        AIRSH_ROW_COUNT=`expr $AIRSH_ROW_COUNT + 1`
        return
    fi

    if [ "$1" == "[" ]; then
        shift
        while [ $# -gt 0 ]; do
            component="${1//-/_}"; shift

            [ "$component" == "]" ] && break
            airsh_component_check "$component"
            eval "AIRSH_ROW_${AIRSH_ROW_COUNT}_RIGHT=\"$component \$AIRSH_ROW_${AIRSH_ROW_COUNT}_RIGHT\""
        done
    else
        airsh_error "Expected [ in row statement"
    fi

    AIRSH_ROW_COUNT=`expr $AIRSH_ROW_COUNT + 1`
}


% do rc_dsl.update({'set': 'airsh_rc_set'})
airsh_rc_set() {
    local name="$1"; shift
    local value="$1"; shift

    # Global set
    if [ -z "${AIRSH_DSL_CURR_COMP}" ]; then
        airshell-set -n $name "$value"
        return
    fi

    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        airsh_warn "Property name '" $name "' is invalid"
        return
    fi

    local target_var="AIRSH_COMP_${AIRSH_DSL_CURR_COMP^^}_PROP_${name^^}"
    if [ -z "${!taret_var}" ]; then
        airsh_warn "Property name '" $name "' does not exist"
        return
    fi

    eval "$target_var=\"$value\""
}

% do rc_dsl.update({'component-style': 'airsh_rc_component_style'})
airsh_rc_component_style() {
    local name="${1}"; shift
    local style="${1}"; shift

    airsh_component_set_prop $name style $style
}


airsh_rc_dsl_install() {
% for alias, func in rc_dsl.items():
    alias {{alias}}={{func}}
% endfor
}


airsh_rc_dsl_uninstall() {
    unalias {{ rc_dsl.keys() | join(' ') }}
}
