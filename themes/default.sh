theme "default"
    config bold 1

    # grey and dark grey
    row-style "243 234"
    row-style "243 233"

    style white     "243 255"
    style silver    "234 245"
    style lightgrey "246 234"
    style blue      "231 31"
    style orange    "231 130"
    style green     "231 22"
    style yellow    "231 22 $AIRSH_THEME_DEFAULT_CONF_BOLD"
    style purple    "231 55 $AIRSH_THEME_DEFAULT_CONF_BOLD"
    style grey      "7 3"
    style default   "243"

    component-style path default
    component-style git-branch orange
    component-style virtualenv green

    row-order 0 white blue orange purple grey
end
