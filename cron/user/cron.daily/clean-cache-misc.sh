#!/bin/bash
# vi: et sts=4 sw=4 ts=4

. ~/.cron/cron.conf

WORKDIR=${0%/*} # (in-bash dirname)
BASE=${0##*/} # (in-bash basename)
MYCONF=$WORKDIR/.$BASE.conf
if [[ ! $MYCONF ]]; then
    printf '%s: Unable to find configuration file "%s"\n' "$0" "$MYCONF" >&2
    exit 1
fi

# Set defaults
DAYS=7

. "$MYCONF" || exit

for dir in "${CACHEDIRS[@]}"; do
    if [[ -d $dir ]]; then

        # remove old files
        (
        find "$dir/" \
            -mindepth 1 \
            -type f \
            ! -name .gitignore \
            -mtime "+$DAYS" \
            -print \
            -delete &&

        # clear out any empty directories, including the cache dir
        # itself
        find "$dir/" \
            -type d \
            -empty \
            -print \
            -delete
        ) >>"$LOG" || exit

    fi
done
