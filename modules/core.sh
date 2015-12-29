module "core"
    prop description "Common system components"
    prop author "Robert Pasiński"
    prop version "1.0.0"


    component "ssh"
        execute() {
            if [ -n "$SSH_CLIENT" ]; then
                airsh_component_return_text "SSH"
            else
                airsh_component_return_none
            fi
        }
    end


    component "user-char"
        config normal_char "\$"
        config root_char "#"

        execute() {
            local char
            if [ `id -u` != "0" ]; then
                char=`airsh_component_get_conf user-char normal_char`
            else
                char=`airsh_component_get_conf user-char root_char`
            fi

            airsh_component_return_text "$char"
        }
    end


    component "virtualenv"
        config show_name false
        config short_path true

        execute() {
            [ -z "$VIRTUAL_ENV" ] && { airsh_component_return_none; return; }
            local name="(env)"
            if [ "$AIRSH_COMP_VIRTUALENV_CONF_SHOW_NAME" = "true" ]; then
                name="$VIRTUAL_ENV"

                if $AIRSH_COMP_VIRTUALENV_CONF_SHORT_PATH; then
                    name=`basename "$name"`
                fi
            fi

            airsh_component_return_text "($VIRTUAL_ENV)"
        }
    end


    component "username"
        execute() {
            airsh_component_return_text "$(whoami)"
        }
    end


    component "hostname"
        execute() {
            airsh_component_return_text "$(uname -n)"
        }
    end


    component "path"
        execute() {
            airsh_component_return_text "$(pwd | sed -e "s/^\/home\/$(whoami)/~/")"
        }
    end


    component "date"
        config format "%H:%M:%S"

        execute() {
            airsh_component_return_text "$(date +$AIRSH_COMP_DATE_CONF_FORMAT)"
        }
    end


    component "command-counter"
        init() {
            AIRSH_COMP_COMMAND_COUNTER_STATE_COUNT=0
        }

        update() {
            ((AIRSH_COMP_COMMAND_COUNTER_STATE_COUNT+=1))
        }

        execute() {
            airsh_component_return_text "$AIRSH_COMP_COMMAND_COUNTER_STATE_COUNT"
        }
    end


    component "last-status"
        config success_char "\u2714"
        config success_color "106"
        config failure_char "\u2718"
        config failure_color "9"

        execute() {
            if [ $AIRSH_LAST_COMMAND_STATUS -eq 0 ]; then
                airsh_component_return_text "$wrap_start\e[1;38;5;${AIRSH_COMP_LAST_STATUS_CONF_SUCCESS_COLOR}m${wrap_end}$AIRSH_COMP_LAST_STATUS_CONF_SUCCESS_CHAR" 1
            else
                airsh_component_return_text "$wrap_start\e[1;38;5;${AIRSH_COMP_LAST_STATUS_CONF_FAILURE_COLOR}m${wrap_end}$AIRSH_COMP_LAST_STATUS_CONF_FAILURE_CHAR" 1
            fi
        }
    end
end
