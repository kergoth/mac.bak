#!/bin/bash

set -euo pipefail

existing_files () {
    "$(dirname "$0")/files_from_mackup.sh" "$app" \
        | while IFS=$'\n' read -r fn; do
            if [ -e "$HOME/$fn" ] || [ -L "$HOME/$fn" ]; then
                echo "$fn"
            fi
        done
}

for app; do
    if [ -n "$(existing_files "$app")" ]; then
        basename "$app" | sed -e 's/\.cfg$//'
    fi
done
