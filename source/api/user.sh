airshell-set() {
    local reload=true

    # no reload
    if [ "$1" == "-n" ]; then
        reload=false
        shift
    fi

    local name="${1}"; shift
    local value="$1"; shift
    local var="AIRSH_CONF_${name^^}"
    var=${var//-/_}
    local value="${!var}"

    if [ -z ${value+t} ]; then
        airsh_error "Configuration variable " $name " does not exist ($var)"
        return
    fi

    eval "$var=$value"
    $reload && airshell-enable
}


airshell-disable() {
    PS1="$AIRSH_ORIGINAL_PS1"
}


airshell-enable() {
    PS1="$(airsh_render_ps1)"
}


airshell-reload() {
    airsh_rc_dsl_install
    if [ -f "$AIRSH_RCFILE" ]; then
        source "$AIRSH_RCFILE"
    fi
    airsh_rc_dsl_uninstall
}


airshell-configure() {
    editor $AIRSH_RCFILE
}


airshell-component-set() {
    local component="$1"; shift
    local key="$1"; shift
    local value="$1"; shift

    airsh_component_set_conf $component $key $value
    airshell-enable
}
