#!/bin/sh

set -eu

scriptdir="$(cd "$(dirname "$0")" && pwd -P)"
PATH="$scriptdir:$PATH"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
config_home="${XDG_CONFIG_HOME#$HOME/}"

for cfg; do
    cat "$cfg" | section_from_mackup.sh configuration_files sandbox_configuration_files
    cat "$cfg" | section_from_mackup.sh xdg_configuration_files | sed -e "s#^#$config_home/#"
done \
    | grep -v '^ *$' \
    | awk '!visited[$0]++'
