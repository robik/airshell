#!/bin/bash

# Airshell prefix without trailing slash
if [ -z "$ASH_PREFIX" ]; then
    ASH_PREFIX="$HOME/.config/airshell"
fi

install_modules()
{
    printf "Modules will be installed in '$ASH_PREFIX/modules'. Do you agree? [Y/n] "
    read result
    case "$result" in
        "n"|"N")
            return
            ;;
            
        *)
            mkdir -p $ASH_PREFIX
            cp -r ./modules $ASH_PREFIX/modules
            echo "Modules installed in $ASH_PREFIX/modules"
    esac
}

check_symbols_installed()
{
    local found_font=0
    local dirs=( "$HOME/.fonts" "/usr/share/fonts/X11/misc" )
    for font_dir in "${dirs[@]}"; do
        if [ -d "$font_dir" ]; then
            if [ -f "$font_dir/PowerlineSymbols.otf" ]; then
                return 0
            fi
        fi
    done
    
    return 1
}  

install_symbols()
{   
    printf "Symbols will be installed in '$HOME/.fonts' and '$HOME/.config/fontconfig/.conf.d'. Do you agree? [Y/n] "
    read result
    case "$result" in
        "n"|"N")
            return
            ;;
    esac
    
    echo "Downloading symbols..."
    pushd /tmp
    mkdir -p $HOME/.fonts
    mkdir -p $HOME/.config/fontconfig/conf.d/
    
    # As specified in https://powerline.readthedocs.org/en/latest/installation/linux.html#font-installation
    [ ! -f "PowerlineSymbols.otf" ] && wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    [ ! -f "10-powerline-symbols.conf" ] && wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mv PowerlineSymbols.otf $HOME/.fonts/
    mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
    popd
    echo "Updating font cache"
    sudo fc-cache -vf ~/.fonts/
    
    if [ $? ]; then
        echo "Success! If you still can't see symbols, try rebooting to apply the changes."
    else
        echo "Error while updating fontconfig cache"
    fi
}

case "$1" in
    "modules")
        install_modules
        ;;
        
    "symbols")
        install_symbols
        ;;
        
    "all")
        install_symbols
        install_modules
        ;;
        
    *)
        echo "Error: Missing or invalid argument. '$1'"
        echo "Usage: $0 {all|symbols|modules}"
esac
