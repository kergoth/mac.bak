#!/bin/sh

set -eu

for section; do
    sed -n -e '/^ *#/d; /^ *\['"$section"'\]$/,/^ *\[/{/^ *\['"$section"'\]$/d; /^ *\[/d; p; }'
done \
    | sed -e 's/ *"//; s/",$//;' \
    | grep -v '^ *$' \
    | awk '!visited[$0]++'
