#!/bin/sh

set -e
( cd mackup && git pull origin master )
if [ -d ~/.mackup ]; then
    ./mackup_to_rsync.sh ~/.mackup apps
fi
./mackup_to_rsync.sh ./mackup/mackup/applications apps
