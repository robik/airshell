module "fun"
    prop description "Fun components"
    prop author "Robert Pasiński"
    prop version "1.0.0"


    component "random-face"
        init() {
            AIRSH_COMP_RANDOM_FACE_FACES=(
                "( ͡° ͜ʖ ͡°)"       "¯\_(ツ)_/¯"       "ʕ•ᴥ•ʔ"       "(▀̿Ĺ̯▀̿ ̿)"
                "ಠ_ಠ"            "(• ε •)"          "(☞ﾟ∀ﾟ)☞"     "(づ￣ ³￣)づ"
                "♪~ ᕕ(ᐛ)ᕗ"      "(╯°□°）╯︵ ┻━┻"    "ヽ༼ຈل͜ຈ༽ﾉ"    "(¬_¬)"
                "ಠ~ಠ"            "°Д°"              "｡゜(｀Д´)゜｡" "ᕦ(ò_óˇ)ᕤ"
                "◉_◉"            "ヾ(⌐■_■)ノ♪"
            )
            AIRSH_COMP_RANDOM_FACE_LENS=(
                8      10      5      6
                3      7       7      12
                8      14      8      5
                3      3       12     8
                3      11
            )
        }

        execute() {
            local index=$(($RANDOM % ${#AIRSH_COMP_RANDOM_FACE_FACES[@]}))
            local face="${AIRSH_COMP_RANDOM_FACE_FACES[$index]}"
            local len=${AIRSH_COMP_RANDOM_FACE_LENS[$index]}
            airsh_component_return_text "$face" $len
        }
    end

    component "spotify-track"
        execute() {
            local res="$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata')"
            airsh_component_return_text "$res"
        }
    end
end
