#!/bin/sh

set -eu

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
config_home="${XDG_CONFIG_HOME#$HOME/}"

for cfg; do
    sed -n -e '/^ *#/d; /^ *\[configuration_files\]$/,/^ *\[/{/^ *\[configuration_files\]$/d; /^ *\[/d; s/ *"//; s/",$//; p; }' "$cfg"
    sed -n -e '/^ *#/d; /^ *\[xdg_configuration_files\]$/,/^ *\[/{/^ *\[xdg_configuration_files\]$/d; /^ *\[/d; s/ *"//; s/",$//; p; }' "$cfg" | sed -e "s#^#$config_home/#"
done \
    | grep -v '^ *$' \
    | awk '!visited[$0]++'
