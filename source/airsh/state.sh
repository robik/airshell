## Path to airshell.sh
AIRSH_PATH=`readlink -f "$0"`

## Directory containing airshell.sh
AIRSH_ROOT_DIR=`dirname "$AIRSH_PATH"`

## Directory in which modules and themes are installed
AIRSH_INSTALL_DIR="${AIRSH_INSTALL_DIR-"$AIRSH_ROOT_DIR"}"

## Path to directory with themes
AIRSH_THEMES_DIR="${AIRSH_THEMES_DIR-"$AIRSH_ROOT_DIR/themes"}"

## Path to directory with modules
AIRSH_MODULES_DIR="${AIRSH_MODULES_DIR-"$AIRSH_INSTALL_DIR/modules"}"

## .airshellrc file location
AIRSH_RCFILE="${AIRSH_RCFILE-"/home/$USER/.airshellrc.sh"}"

## Theme name
# Set with `use-theme` in rcfile
AIRSH_THEME="${AIRSH_THEME-"default"}"

## Modules for left and right parts
AIRSH_ROW_COUNT=0

# For each row following variables are added (starting from 0)
# AIRSH_ROW_#_LEFT=()
# AIRSH_ROW_#_RIGHT=()

## Modules rendered before input (at the same line)
AIRSH_PREFIX_COMPONENTS=()

# List of loaded modules
AIRSH_MODULES_LOADED=()

## List of registered components
AIRSH_COMPONENTS_LOADED=()

## List of components with passed init()
AIRSH_COMPONENTS_AVAILABLE=()

## List of components with update method
AIRSH_COMPONENTS_WITH_UPDATE=()

AIRSH_FAIL=1
AIRSH_OK=0
AIRSH_STATUS=0 # 0 for true
AIRSH_LAST_COMMAND_STATUS=0

AIRSH_CONF_NEWLINE=true
AIRSH_CONF_AUTO_START=true
AIRSH_CONF_THEME="default"

AIRSH_CONF_LEFT_DELIM="\ue0b0"
AIRSH_CONF_RIGHT_DELIM=""
#AIRSH_CONF_RIGHT_DELIM="\ue0b2"

AIRSH_ORIGINAL_PS1="$PS1"
