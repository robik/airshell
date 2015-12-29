% set module_dsl = {}

% do module_dsl.update({'module': 'airsh_module_dsl_start_module'})
airsh_module_dsl_start_module() {
    local name="${1//-/_}"; shift

    AIRSH_MODULE_DSL_MODULE="$name"
    eval "AIRSH_MOD_${AIRSH_MODULE_DSL_MODULE^^}_EXPORTS=()"
}


_airsh_module_dsl_apply_component() {
    airsh_func_exists execute
    if [ $? -ne $AIRSH_OK ]; then
        airsh_error "" "execute" " function not defined in component " $AIRSH_MODULE_DSL_COMPONENT
        unset AIRSH_MODULE_DSL_COMPONENT
        return
    fi

    if airsh_func_exists init; then
        local src=`airsh_func_get_source init`
        eval "airsh_comp_${AIRSH_MODULE_DSL_COMPONENT,,}__init() $src"
        unset init
    fi

    if airsh_func_exists update; then
        local src=`airsh_func_get_source update`
        eval "airsh_comp_${AIRSH_MODULE_DSL_COMPONENT,,}__update() $src"
        unset update
        AIRSH_COMPONENTS_WITH_UPDATE+=("${AIRSH_MODULE_DSL_COMPONENT,,}")
    fi

    if [ ! -z "$AIRSH_MODULE_DSL_MODULE" ]; then
        eval "AIRSH_MOD_${AIRSH_MODULE_DSL_MODULE^^}_EXPORTS+=(\"$AIRSH_MODULE_DSL_COMPONENT\")"
    fi

    AIRSH_COMPONENTS_LOADED+=("$AIRSH_MODULE_DSL_COMPONENT")
    local src=`airsh_func_get_source execute`
    eval "airsh_comp_${AIRSH_MODULE_DSL_COMPONENT,,}() $src"
    unset execute
}

% do module_dsl.update({'end': 'airsh_module_dsl_end'})
airsh_module_dsl_end() {
    if [ ! -z "$AIRSH_MODULE_DSL_COMPONENT" ]; then
        _airsh_module_dsl_apply_component
        unset AIRSH_MODULE_DSL_COMPONENT
    elif [ ! -z "$AIRSH_MODULE_DSL_MODULE" ]; then
        unset AIRSH_MODULE_DSL_MODULE
    else
        airsh_error "Unmatched 'end'"
    fi
}


% do module_dsl.update({'component': 'airsh_module_dsl_start_component'})
airsh_module_dsl_start_component() {
    local name="${1//-/_}"; shift

    AIRSH_MODULE_DSL_COMPONENT="$name"
}


% do module_dsl.update({'prop': 'airsh_module_dsl_set'})
airsh_module_dsl_set() {
    local name="${1}"; shift
    local value="$1"; shift
    local func_name="set"

    # for wrappers
    if [ $# -gt 0 ]; then
        func_name="$1"
    fi

    if [ ! -z "$AIRSH_MODULE_DSL_COMPONENT" ]; then
        airsh_component_set_prop $AIRSH_MODULE_DSL_COMPONENT $name $value
    elif [ ! -z "$AIRSH_MODULE_DSL_MODULE" ]; then
        airsh_module_set_prop $AIRSH_MODULE_DSL_MODULE $name $value
    else
        airsh_error "" "$func_name" " is neither in " module " or " component " scope"
    fi
}


% do module_dsl.update({'config': 'airsh_module_dsl_config'})
airsh_module_dsl_config() {
    local name="$1"; shift
    local value="$1"; shift

    airsh_module_dsl_set "conf_$name" "$value" "config"
}


_airsh_module_dsl_guard_module() {
    local func_name="$1"; shift

    if [ -z "$AIRSH_MODULE_DSL_MODULE" ]; then
        airsh_error "Using '" $func_name "' not in module definiton scope"
    fi
}


airsh_module_dsl_install() {
% for alias, value in module_dsl.items():
    alias {{alias}}={{value}}
% endfor
}


airsh_module_dsl_uninstall() {
    unalias {{ module_dsl.keys() | join(' ') }}
}
