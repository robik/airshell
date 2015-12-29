### TERMINAL COLORS

% set color_names = ['black', 'red', 'green', 'brown', 'blue', 'purple', 'cyan', 'grey']
% set light_color_aliases = {'brown': 'yellow', 'black': 'grey', 'grey': 'white'}

AIRSH_ANSI_RESET='\e[0m'

{% for name in color_names %}
AIRSH_FG_{{name | upper}}='\e[0;{{loop.index0 + 30}}m'
AIRSH_BG_{{name | upper}}='\e[{{loop.index0 + 40}}m'
{% if name in light_color_aliases %}
{% set name = light_color_aliases[name] %}
{% else %}
{% set name = 'light_' + name %}
{% endif %}
AIRSH_FG_{{name | upper}}='\e[1;{{loop.index0 + 30}}m'

% endfor
