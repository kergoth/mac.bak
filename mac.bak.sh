#!/usr/bin/env bash

# mac.bak.sh v1.1.1
# author: mattmc3
# revision: 2018-01-25

# Run backups to whatever directory you specify

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function usage() {
    echo "Usage:"
    echo "mac.bak.sh "
    echo "mac.bak.sh -h "
    echo "mac.bak.sh [--dir=~/backups] [APP_NAME..] "
    echo ""
    echo "   -d | --dir         the backup directory"
    echo "   --dry-run          rsync dry run rather than backup"
    echo "   --delete-excluded  rsync delete excluded"
    echo "   -h                 help (this output)"
}

# vars
backupdir="${current_dir}/backups"
app_dir="${current_dir}/apps"
custom_dir="${current_dir}/custom"
rsync_combined="${current_dir}/include-from.rsync"
dry_run=
delete_excluded=

# parse command args
while [ "$1" != "" ]; do
    case $1 in
        --)
            shift
            break
            ;;
        -d | --dir)
            shift
            backupdir=${1%/}
            shift
            ;;
        --dry-run)
            dry_run=1
            shift
            ;;
        --delete-excluded)
            delete_excluded=1
            shift
            ;;
        -*)
            usage
            exit
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -eq 0 ]; then
    echo "Backing up everything to ${backupdir}"
    app_msg=0
    # shellcheck disable=SC2046
    set -- $(find "$app_dir" -type f -a \( -name \*.rsync -o -name backup.sh \) | sed -e 's#/[^/]*$##; s#.*/##; s#\.cfg$##' | sort -u)
else
    app_msg=1
fi

rm -f "${rsync_combined}.tmp"
for app_name; do
    if [[ $app_msg -eq 1 ]]; then
        echo "Backing up ${app_name} to ${backupdir}"
    fi
    this_app_dir="${app_dir}/${app_name}"

    # first run all backup.sh scripts
    if [[ -z $dry_run ]]; then
        find "${this_app_dir}" -type f -name 'backup.sh' -exec {} \;
    else
        echo "skipping backup.sh scripts for dry-run"
    fi

    # get all rsync instructions files into one
    find "${this_app_dir}" -type f -name 'include-from.rsync' -exec cat {} \; >>"${rsync_combined}.tmp"
    find "${custom_dir}" -type f -name 'include-from.rsync' -exec cat {} \; >>"${rsync_combined}.tmp"
done

# `awk '!/[^\#]/ || !seen[$0]++'` is a uniq trick without the need for a sort
cat "${rsync_combined}.tmp" | awk '!/[^#]/ || !seen[$0]++' >"${rsync_combined}"
rm "${rsync_combined}.tmp"

# rsync
rsync_cmd="rsync -acvX "
if [[ -n $dry_run ]]; then
    rsync_cmd+="--dry-run "
fi
if [[ -n $delete_excluded ]]; then
    rsync_cmd+="--delete-excluded "
fi
rsync_cmd+="--include-from=\"${current_dir}/header.rsync\" "
rsync_cmd+="--include-from=\"${rsync_combined}\" "
rsync_cmd+="--include-from=\"${current_dir}/footer.rsync\" "
rsync_cmd+="\"$HOME/\" \"$backupdir/\""

echo $rsync_cmd
eval $rsync_cmd
rm "${rsync_combined}"
