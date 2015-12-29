#!/bin/bash

#! {{ generate_warning }}

#! AirShell - Airline inspired Bash prompt
#! Copyright 2015 Robert Pasiński
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# GitHub repository:
#   https://github.com/robik/airshell


# If not interactive, skip
[[ -z "$PS1" && -z "$AIRSH_DEBUG" ]] && return

% include 'airsh/state.sh'
% include 'airsh/ansi.sh'
% include 'airsh/utils.sh'
% include 'airsh/module.sh'
% include 'airsh/component.sh'
% include 'airsh/theme.sh'
% include 'airsh/render.sh'
% include 'api/user.sh'
% include 'api/rcfile.sh'
% include 'api/module.sh'
% include 'api/theme.sh'

airsh_theme_load "default"
airsh_module_load "core"

# Check for config file existence
airsh_rc_dsl_install
if [ -f "$AIRSH_RCFILE" ]; then
    source "$AIRSH_RCFILE"
fi
airsh_rc_dsl_uninstall

if [ $AIRSH_STATUS -eq $AIRSH_FAIL ] ; then
    return
fi

prompt_command() {
    AIRSH_LAST_COMMAND_STATUS=$?
    local component

    for component in ${AIRSH_COMPONENTS_WITH_UPDATE[@]}; do
        eval "airsh_comp_${component}__update"
    done
}
PROMPT_COMMAND=prompt_command

if $AIRSH_CONF_AUTO_START; then
    airshell-enable
fi
