% set theme_dsl = {}

% do theme_dsl.update({'theme': 'airsh_theme_dsl_start'})
airsh_theme_dsl_start() {
    local name="${1//-/_}"; shift

    AIRSH_THEME_DSL_ROW_INDEX=0
    AIRSH_THEME_DSL_NAME="$name"
}

% do theme_dsl.update({'component-style': 'airsh_theme_dsl_component_style'})
airsh_theme_dsl_component_style() {
    _airsh_theme_dsl_guard "component-style"

    local name="${1}"; shift
    local style="${1}"; shift

    airsh_component_set_prop $name style $style
}

% do theme_dsl.update({'row-order': 'airsh_theme_dsl_row_order'})
airsh_theme_dsl_row_order() {
    _airsh_theme_dsl_guard "row-order"

    local row_i=$1; shift
    local styles="$@";

    airsh_theme_set_prop $AIRSH_THEME_DSL_NAME row_${row_i}_styles "$styles"
}


% do theme_dsl.update({'end': 'airsh_theme_dsl_end'})
airsh_theme_dsl_end() {
    _airsh_theme_dsl_guard "end"

    if airsh_func_exists init; then
        local src=`airsh_func_get_source init`
        eval "airsh_theme_${AIRSH_THEME_DSL_NAME,,}__init() $src"
        unset init
    fi

    unset AIRSH_THEME_DSL_ROW_INDEX
    unset AIRSH_THEME_DSL_NAME
}


% do theme_dsl.update({'prop': 'airsh_theme_dsl_set'})
airsh_theme_dsl_set() {
    _airsh_theme_dsl_guard "prop"

    local name="${1^^}"; shift
    local value="$1"; shift

    airsh_theme_set_prop $AIRSH_THEME_DSL_NAME $name "$value"
}

% do theme_dsl.update({'row-style': 'airsh_theme_dsl_row'})
airsh_theme_dsl_row() {
    _airsh_theme_dsl_guard "row"
    local colors=($1); shift

    airsh_theme_set_prop $AIRSH_THEME_DSL_NAME row_${AIRSH_THEME_DSL_ROW_INDEX}_fg "${colors[0]}"
    airsh_theme_set_prop $AIRSH_THEME_DSL_NAME row_${AIRSH_THEME_DSL_ROW_INDEX}_bg "${colors[1]}"
    ((AIRSH_THEME_DSL_ROW_INDEX+=1))
}


% do theme_dsl.update({'style': 'airsh_theme_dsl_style'})
airsh_theme_dsl_style() {
    _airsh_theme_dsl_guard "add"

    local name="${1}"; shift
    local styles=($1); shift
    local styles_var="$(airsh_theme_get_var $AIRSH_THEME_DSL_NAME styles)"
    airsh_theme_set_prop $AIRSH_THEME_DSL_NAME style_${name}_bg "${styles[1]}"

    eval "$styles_var+=(\"$name\")"
    value="$(airsh_theme_dsl_parse_style ${styles[@]})"
    airsh_theme_set_prop $AIRSH_THEME_DSL_NAME style_$name "$value"
}


% do theme_dsl.update({'config': 'airsh_theme_dsl_config'})
airsh_theme_dsl_config() {
    _airsh_theme_dsl_guard "config"

    local name="$1"; shift
    local value="$1"; shift

    airsh_theme_dsl_set "conf_$name" "$value"
}


airsh_theme_dsl_parse_style() {
    local fore=$1; shift
    local back=$1; shift
    local extra="$1"; shift
    local res=""
    local row_i=$(($AIRSH_THEME_DSL_ROW_INDEX-1))

    res="\e[38;5;${fore}"
    if [ "$back" != "" ]; then
        res+=";48;5;${back}"
    fi
    if [ "$extra" != "" ]; then
        res+=";$extra"
    fi
    res+="m"
    echo -e "$res"
}


_airsh_theme_dsl_guard() {
    local func_name="$1"; shift

    if [ -z "$AIRSH_THEME_DSL_NAME" ]; then
        airsh_error "Using '" $func_name "' not in theme definiton scope"
    fi
}


airsh_theme_dsl_install() {
% for alias, value in theme_dsl.items():
    alias {{alias}}={{value}}
% endfor
}


airsh_theme_dsl_uninstall() {
    unalias {{ theme_dsl.keys() | join(' ') }}
}
