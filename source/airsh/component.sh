airsh_component_is_available() {
    local name="$1"; shift

    airsh_array_has_element "$name" ${AIRSH_COMPONENTS_AVAILABLE[@]}
}


airsh_component_check() {
    local name="$1"; shift

    airsh_component_is_available $name
    if [ $? -ne $AIRSH_OK ] ; then
        airsh_error "Component " $name " is not available (are you sure you loaded the parent module?)"
        AIRSH_STATUS=$AIRSH_FAIL
    fi
}


airsh_component_get_module() {
    local module
    local component="$1"; shift

    for module in ${AIRSH_MODULES_LOADED[@]}; do
        local components="$(airsh_module_get_prop -a exports)"

        if airsh_array_has_element "$component" ${components[@]}; then
            echo "$module"
            return
        fi
    done

    return $AIRSH_FAIL
}


airsh_component_get_prop() {
    local component="${1^^}"; shift
    local key="${1^^}"; shift
    component=${component//-/_}
    key=${key//-/_}

    { airsh_assert_name $key; } && return
    local var="AIRSH_COMP_${component}_${key}"
    echo "${!var}"
}


airsh_component_set_prop() {
    local component="${1^^}"; shift
    local key="${1^^}"; shift
    local value="$1"; shift
    component=${component//-/_}
    key=${key//-/_}
    local target_var="AIRSH_COMP_${component}_${key}"

    { airsh_assert_name $key; } && return
    if [ -z "$target_var" ]; then
        airsh_warn "Key $key does not exist ($target_var)"
        return
    fi

    eval "$target_var=\"$value\""
}


airsh_component_get_conf() {
    local component="$1"; shift
    local key="$1"; shift

    airsh_component_get_prop $component "conf_$key"
}


airsh_component_set_conf() {
    local component="$1"; shift
    local key="$1"; shift
    local value="$1"; shift

    airsh_component_set_prop $component "conf_$key" $value
}


airsh_component_return_text() {
    AIRSH_COMPONENT_RESULT="$1"; shift

    if [ $# -lt 1 ]; then
        AIRSH_COMPONENT_LENGTH="${#AIRSH_COMPONENT_RESULT}"
    else
        AIRSH_COMPONENT_LENGTH="$1"
    fi
}


airsh_component_return_none() {
    AIRSH_COMPONENT_RESULT=""
    AIRSH_COMPONENT_LENGTH="-1"
}
