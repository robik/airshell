---
layout: default
title: Configuration
permalink: /configuration/
---

### Contents

* TOC
{:toc}


### Introduction

Before describing airshell configuration, you must know how everything is organised.

Prompt consists of two parts: rows and prefix. Both aggregate components,
which are those colorful widgets you've might seen on previous page.
Rows have two "anchors" you can add components to, left and right.
Prefix can have components only on left side, as it is the part that is displayed on the same line as input.

Components are provided by modules, which are essentially a collection of components.
To use a component, you must load the containing module.
The `core` module is loaded automatically, so you have few simple components available by default.

Components can be attached a style, which defines its appearance. Styles are provided by themes, which, just like
modules must be loaded beforehand. And just like `core` module, `default` theme is loaded automatically.
When not attaching a style manually, a theme definition order is used.
That is, component in row will be attached a style from theme in order it was defined
(this repeats across rows and anchors). Components on right anchor are styled
from right to left (this rule includes hidden components).


Airshell, themes and components can define configurable properties, which you can change.
All custom configuration overrides should be kept in `~/.airshellrc.sh` file. It is loaded every time
AirShell is started. The file is a bash source, so make sure its syntax is correct.


<div class="alert alert-info" role="alert">
    <strong>Heads up!</strong>
    You can change location and name of the <code>.airshellrc.sh</code> file.

    <p>To do this, simply set <code>AIRSH_RCFILE</code> variable to location of new file to load. Make sure you set it
    <strong>before</strong> actually loading <code>airshell.sh</code></p>
</div>

To simplify configuration, AirShell implements a small DSL (domain specific language) for configuration files.
Before the file is loaded, new helpers are added for use in configuration and later removed, to not pollute the global "scope".
So don't be suprised when you try to use them in your terminal and it doesn't work (there's another set of helpers to use in terminal, however).

Here is an example configuration file to give you and idea how it looks like:

{% highlight bash %}
# load-theme name
load-module git

set auto-start true
set newline true
set right-delim "\ue0b2"

row [ username hostname ] [ git-branch ]
row [ path ]
prefix [ user-char ]

component-style username orange
{% endhighlight %}

---

{% include config_more.html %}

---

### Commands

#### __`load-theme`__

`load-theme name`

Loads theme `name`. This function, however, does not enable it.
Theme is loaded from `$AIRSH_THEMES_DIR/name.sh`, which with default
configuration expands to `$AIRSH_INSTALL_DIR/themes/name.sh`.
Theme `default` is loaded automatically.


#### __`load-module`__

`load-module name`

Loads modules with names name (resolved to `$AIRSH_MODULES_DIR/name.sh`).
Module `core` is loaded automatically.


#### __`load-all-modules`__

`load-all-modules`

Loads all modules that are present in `$AIRSH_MODULES_DIR` directory.


#### __`set`__

`set name value`

Use this function to set global configuration properties. Property names are case insensitive and
 dashes (`-`) are replaced with underscores (`_`).


#### __`row`__

`row [ left-component left-component... ] [ right-component right-component... ]`

Creates new row displayed before input. `left-components` is list of component
names separated by space. `right-components` (with square brackes) is optional and specifies components
displayed on right side.

Square brackets are required before and after list of components, and they
 must be surrounded by space!

Just as properties, component names are case insensitive and
 dashes (`-`) are replaced with underscores (`_`).


#### __`prefix`__

`prefix [ component component... ]`

Sets components to be displayed in the same line as user input.

Square brackets are not required and are only for aesthics. If present they
 must be surrounded by space!


#### __`component-style`__

`component-style component style`


Tells airshell that `component` should be styled with `style`.
If style is not available component won't be styled at alls.

<div class="alert alert-info" role="alert">
    <strong>Heads up!</strong>
    Component style overrides must be placed after <code>load-theme</code> directive.
</div>
