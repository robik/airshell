airsh_render_fill_row() {
    local bg_color="$1"; shift
    local cols=$(tput cols)

    printf "\e[48;5;${bg_color}m%${cols}s\e[399D"
}


airsh_render_row_left() {
    local wrap_start=""
    local wrap_end=""

    if [ "$1" = "-p" ]; then
        wrap_start="\x01" # work exactly as \[ and \]
        wrap_end="\x02"
        shift
    fi

    local row_i=$1; shift

    local components=()
    local components_len=$#
    local components_i=0
    local result_var
    local comp_styles=()
    local comp_bgs=()
    local row_styles=($(airsh_current_theme_get_prop -a row_${row_i}_styles))
    local i=0 # keeps original index before filtering

    if [ ${#row_styles[@]} -eq 0 ]; then
        row_styles=($(airsh_current_theme_get_prop -a styles))
    fi

    # Evaluate components
    for component in $@; do
        eval "airsh_comp_${component}"
        if [ "$AIRSH_COMPONENT_LENGTH" = "-1" ]; then
            ((i+=1))
             continue
         fi
        components+=("$component")
        eval "local comp_result_$components_i=\"$AIRSH_COMPONENT_RESULT\""

        # if override exists
        local style_name="$(airsh_component_get_prop $component style)"
        if [ "$style_name" = "" ]; then
            style_name="${row_styles[$(($i % ${#row_styles}))]}"
        fi
        comp_styles+=("$(airsh_current_theme_get_style $row_i $style_name)")
        local style_bg="$(airsh_current_theme_get_prop style_${style_name}_bg)"
        comp_bgs+=("${style_bg:-$(airsh_current_theme_get_prop row_${row_i}_bg)}")

        ((i+=1))
        ((components_i+=1))
    done

    # -p is passed on prefix line and we leave here last delimeter bg default rather than row color
    if [ -z "$wrap_start" ]; then
        comp_bgs+=("$(airsh_current_theme_get_prop row_${row_i}_bg)")
    fi

    components_len=$components_i
    components_i=0

    # Display filtered components
    for component in ${components[@]}; do
        result_var="comp_result_$components_i"

        printf "$wrap_start%s$wrap_end ${!result_var} $wrap_start\e[0m$wrap_end" "${comp_styles[$components_i]}"

        if [ $components_i -lt `expr $components_len` ]; then
            local next_i=`expr $components_i + 1`
            #echo "i: $components_i, next: $next_i, nextc: $next_component"
            printf "$wrap_start\e[38;5;%s;48;5;%sm$wrap_end$AIRSH_CONF_LEFT_DELIM" "${comp_bgs[$components_i]}" "${comp_bgs[$next_i]}"
        fi

        ((components_i+=1))
    done
}


airsh_render_row_right() {
    # Goto end of the line
    printf "\e[499C"

    local row_i=$1; shift
    local components=()
    local components_len=$#
    local components_i=0
    local result_var
    local length_var
    local comp_styles=()
    local comp_bgs=()
    local row_styles=($(airsh_current_theme_get_prop -a row_${row_i}_styles))
    local i=0 # keeps original index before filtering

    if [ ${#row_styles[@]} -eq 0 ]; then
        row_styles=($(airsh_current_theme_get_prop -a styles))
    fi

    # Evaluate components to skip hidden
    for component in $@; do
        eval "airsh_comp_${component}"
        [ "$AIRSH_COMPONENT_LENGTH" = "-1" ] && continue
        components+=("$component")
        eval "local comp_result_$components_i=\"$AIRSH_COMPONENT_RESULT\""
        eval "local comp_length_$components_i=\"$AIRSH_COMPONENT_LENGTH\""

        # if override exists
        local style_name="$(airsh_component_get_prop $component style)"
        if [ "$style_name" = "" ]; then
            style_name="${row_styles[$(($i % ${#row_styles}))]}"
        fi
        comp_styles+=("$(airsh_current_theme_get_style $row_i $style_name)")
        local style_bg="$(airsh_current_theme_get_prop style_${style_name}_bg)"
        comp_bgs+=("${style_bg:-$(airsh_current_theme_get_prop row_${row_i}_bg)}")

        ((i+=1))
        ((components_i+=1))
    done

    comp_bgs+=("$(airsh_current_theme_get_prop row_${row_i}_bg)")
    components_len=$components_i
    components_i=0

    # Display filtered components
    for component in ${components[@]}; do
        result_var="comp_result_$components_i"
        length_var="comp_length_$components_i"

        local component_length=${!length_var}

        # Move cursor back and draw delimeter
        if [ "$AIRSH_CONF_RIGHT_DELIM" != "" ]; then
            ((component_length+=2))
            printf "\e[${component_length}D"
            printf "\e[38;5;%s;48;5;%sm$AIRSH_CONF_RIGHT_DELIM" "${comp_bgs[$components_i]}" "${comp_bgs[$(($components_i + 1))]}"
        else
            ((component_length+=1))
            printf "\e[${component_length}D"
        fi

        printf "%s ${!result_var} \e[0m" "${comp_styles[$components_i]}"

        ((component_length+=2))
        printf "\e[${component_length}D"
        ((components_i+=1))
    done

    printf "\e[299C\e[0m\n"
}

airsh_render_rows() {
    local i=0
    while [ $i -lt $AIRSH_ROW_COUNT ]; do
        airsh_render_fill_row $(airsh_current_theme_get_prop row_${i}_bg)

        local left_var="AIRSH_ROW_${i}_LEFT"
        local right_var="AIRSH_ROW_${i}_RIGHT"

        # Build list of non-empty modules
        airsh_render_row_left $i ${!left_var}
        airsh_render_row_right $i ${!right_var}
        ((i+=1))
    done
}


airsh_render_prefix() {
    local last_index=`expr ${#AIRSH_PREFIX_COMPONENTS[@]} - 1`
    local last_component="${AIRSH_PREFIX_COMPONENTS[$last_index]}"
    airsh_render_row_left -p 0 ${AIRSH_PREFIX_COMPONENTS[@]}
}


airsh_render_ps1() {
    printf "\[$AIRSH_ANSI_RESET\]"
    if $AIRSH_CONF_NEWLINE; then
        echo
    fi

    echo "\[\$(airsh_render_rows)\]"
    if [ ${#AIRSH_PREFIX_COMPONENTS[@]} -gt 0 ]; then
        printf "\$(airsh_render_prefix)"
    fi
    printf "\[$AIRSH_ANSI_RESET\] "
}
