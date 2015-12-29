airsh_module_load() {
    local name="$1"; shift
    local location="$AIRSH_MODULES_DIR/$name.sh"

    if airsh_module_is_loaded $name; then
        return
    fi

    if [ ! -f $location ]; then
        airsh_error "Module '" $name "' cannot be found (is it installed?): '" $location "'"
        return
    fi

    AIRSH_MODULES_LOADED+=("$name")

    airsh_module_dsl_install
    . $location
    if airsh_func_exists "airsh_mod_${name,,}__init"; then
        eval "airsh_mod_${name,,}__init"
    fi
    airsh_module_dsl_uninstall

    local res
    local component
    for component in `airsh_module_get_prop -a $name "exports"`; do
        if ! airsh_array_has_element $component ${AIRSH_COMPONENTS_AVAILABLE[@]}; then
            if airsh_func_exists "airsh_comp_${component}__init"; then
                eval "airsh_comp_${component}__init; res=$?"
                if [ $res -eq $AIRSH_OK ]; then
                    AIRSH_COMPONENTS_AVAILABLE+=("$component")
                fi
            else
                AIRSH_COMPONENTS_AVAILABLE+=("$component")
            fi
        fi
    done
}


airsh_module_is_loaded() {
    local name="$1"; shift

    airsh_array_has_element "$name" ${AIRSH_MODULES_LOADED[@]}
}


airsh_module_get_prop() {
    local array=false
    if [ "$1" = "-a" ]; then
        array=true
        shift
    fi

    local module=${1^^}; shift
    local name="${1^^}"; shift
    module=${module//-/_}
    name=${name//-/_}

    { airsh_assert_name $name; } && return
    if $array; then
        name="$name[@]"
    fi
    local var="AIRSH_MOD_${module}_${name}"
    echo "${!var}"
}


airsh_module_set_prop() {
    local module=${1^^}; shift
    local name="${1^^}"; shift
    local value="$1"; shift
    module=${module//-/_}
    name=${name//-/_}

    { airsh_assert_name $name; } && return
    eval "AIRSH_MOD_${module}_${name}=\"$value\""
}


airsh_module_get_conf() {
    local module=${1^^}; shift
    local name="${1^^}"; shift

    echo `airsh_module_get_prop "$module" "CONF_$name"`
}


airsh_module_set_conf() {
    local module=${1^^}; shift
    local name="${1^^}"; shift

    echo `airsh_module_set_prop "$module" "CONF_$name"`
}
