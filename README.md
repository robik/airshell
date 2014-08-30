airshell
========

Customisable and extendable Powerline/Airline inspired Bash prompt.

![Airshell Prompt](http://i.imgur.com/afr1es3.png)


### Requirements

 - Terminal emulator that supports 256bit colors.


### Issues

 - If airshell does not work correctly, feel free to report the issue [here](https://github.com/robik/airshell/issues).


### Installation 

Clone this repository and execute `install.sh` file.

```
git clone https://github.com/robik/airshell
bash install.sh all
```

To test airshell without making any changes, simply do `source airshell.bash` in repository directory. Some symbols may not be displayed correctly, to fix this run `install.sh all`. If it still does not help follow [these](https://powerline.readthedocs.org/en/latest/installation/linux.html#font-installation) instructions.

If you wish you can use `airshell.bash` as typical `.bashrc` file. Either save it as `~/.bashrc` or add
`source ~/path/to/airshell.bash` statement in your `.bashrc`. If it suddenly stops "working", you can execute `disable_airshell` to restore original prompt.

For default theme it is advised (and also only working solution) to use it in terminal emulator with black background and while foreground.


### File Structure

By default Airshell's config and modules live in `~/.config/airshell`. This path can be changed by changing `ASH_PREFIX` variable in `airshell.bash`. This directory contains two entries:

Name        | Description
------------|--------------------------
`modules/`  | Directory with modules loaded by airshell. All modules must have either `bash` or `sh` extension to be loaded.
`theme`     | Bash file that override default airshell configuration.


### Modules

Airshell allows to extend functionality with _modules_. Modules can be freely placed on prompt-bar and have distinct configuration. Airshell comes with few builtin modules, such as `user` which prints username, `git` with prints branch name if available etc. All modules should be kept in `$ASH_PREFIX/modules` directory.

Module's foreground and background can be changed in `MODULE_{name}_FG` and `MODULE_{name}_BG` variables respectively, where `{name}` should be replaced with uppercase name of the module. Described in detail in [Customization](#Customization) section.

A module may not be rendered if some internal condition is not met. In such case whole module block is skipped. Example of such module is `git`, which is rendered only if current directory is in a valid `git` repository.

Modules order can be changed for left size and right side of the bar with `LEFT_MODULES` and `RIGHT_MODULES` variables.
Both variables are arrays of lowercase module names ordered in display order. Having an unkown module in those arrays results in an error.

Modules are described in detail in [`Creating a module`](#Creating_a_module) section.


### Customization

Airshell uses [_ANSI escape sequences_](http://en.wikipedia.org/wiki/ANSI_escape_code) to colorize output. All ANSI sequences start with `ESC[` (`\e[` in bash) and most but not all end with `m`.

__Simple colors table__

Color name  | Black | Red | Green | Yellow | Blue | Magenta | Cyan |  White
------------|-------|-----|-------|--------|------|---------|------|--------------
Color number| 0     | 1   | 2     | 3      | 4    | 5       | 6    |  7

Information on advanced colors is available on [wikipedia page](http://en.wikipedia.org/wiki/ANSI_escape_code#Colors).

__Common sequences table__

Sequence          | Result
------------------|----------------------------------------
`\e[0m`           | Reset foreground, background and font changes.
`\e[1m`           | Enable font bold.
`\e[30m`-`\e[37m` | Changes foreground color. `30+x` where `x` is color number.
`\e[40m`-`\e[47m` | Changes background color. `40+x` where `x` is color number.
`\e[38;5;{n}m`    | Changes foreground color, where `{n}` is color number between `0` and `255`.
`\e[48;5;{n}m`    | Changes background color, where `{n}` is color number between `0` and `255`.
`\e[38;2;{r};{g};{b}m` | Changes foreground color, where `{[rgb]}` is color value between `0` and `255`.
`\e[48;5;{r};{g};{b}m` | Changes background color, where `{[rgb]}` is color value between `0` and `255`.

All Airshell options must be global variables. They can be defined/overriden in either `airshell.bash` or in `$ASH_PREFIX/theme` files.

__Configuration variables__

_All `{name}` slugs below must be replaced with uppercase module name_

Variable name         | Variable description
----------------------|----------------------------------------------------
`MODULE_{name}_BG`    | Module background color. This variable __must hold__ 256bit background color sequence between `\e[48;` and `m`. That is only `5;{n}` and `2;{r};{g};{b}` sequences are allowed.
`MODULE_{name}_FG`    | Module foreground. This variable can hold sequences without `\e[` and `m`. Can be used to make font bold (`1`) and change foreground color `30-37` and `38`.
`COLOR_HEADER_BG`     | Header row background. Same as `MODULE_{name}_BG` value will be pasted as `\e[48;{VALUE}m`
`LEFT_MODULES`        | List of module names that will be rendered on the left side.
`RIGHT_MODULES`       | List of module names that will be rendered on the right side.
`PS1_MODULE`          | Module that is rendered in the second row before input. May be changed to module-list in futher versions.
`PS2_CHAR`            | Character rendered in `PS2`.
`RIGHT_MODULE_DELIM`  | Right modules delimeter character.
`LEFT_MODULE_DELIM`   | Left modules delimeter character.
`BRANCH_CHAR`         | Character displayed in git module.


### Creating a module

To create a custom module, create a file in `$ASH_PREFIX/modules` directory. Ensure that file name has either `bash` or `sh` extension. Then add a function `ash_module_{name}` where `{name}` is lowercase name of your module.

Modules should not write any output directly. Instead `ash_return_text` and `ash_return_none` functions should be used. Both functions do not stop futher function exection.

Calling `ash_return_none` signals that module block should not be rendered. 

`ash_return_text` takes one or two arguments, first argument is required and is module output to render. 
Second, optional argument is output length that is calculated from first argument. 
It is important that if module output contains esacape sequences or simply module string is different than rendered, second argument must contain calculated rendered output width WITHOUT any escape sequences.

Here's code snippet of `git` module:

```bash
ash_module_git()
{   
    local res="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ "$res" != "" ]; then
        ash_return_text "$BRANCH_CHAR $res" `expr ${#res} + 2`
    else
        ash_return_none
    fi
}
```

Optionally, all modules can have validation checker function named `ash_validate_module_{name}`. They can check required dependencies and optionally install them. Validation functions are executed once at beggining of terminal session. If validation fails module will not be rendered.

Here's how `git` module used it to check for `git` command.

```bash
ash_validate_module_git()
{
    if [[ $? && ! -x "$(which git)" ]]; then
        printf "\e[1;31mConfiguration Error\e[0m: Git command not found. Either install git or remove git module.\n"
        return $ASH_VALIDATION_FAILURE
    fi
    return $ASH_VALIDATION_SUCCESS
}
```
