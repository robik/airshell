module "git"
    prop description "Git support for Airshell"
    prop author "Robert Pasiński"
    prop version "1.0.0"


    component "git-branch"
        config show-char true
        config branch-char "\ue0a0"

        init() {
            if [[ $? && ! -x "$(which git)" ]]; then
                airsh_warn "" "git" " command not found. Either install " "git" " or remove git module."
                echo -e "\n\t apt-get install git"
                return $AIRSH_FAIL
            fi
            return $AIRSH_OK
        }


        execute() {
            local res="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
            local prefix=""
            local add=0

            if $AIRSH_COMP_GIT_BRANCH_CONF_SHOW_CHAR; then
                prefix="$AIRSH_COMP_GIT_BRANCH_CONF_BRANCH_CHAR "
                add=2 # char and space
            fi

            if [ "$res" != "" ]; then
                airsh_component_return_text "$prefix$res" `expr ${#res} + $add`
            else
                airsh_component_return_none
            fi
        }
    end
end
