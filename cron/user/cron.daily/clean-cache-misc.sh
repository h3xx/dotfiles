#!/bin/bash
# vi: et sts=4 sw=4 ts=4

. ~/.cron/cron.conf

WORKDIR=${0%/*}
BASE=${0##*/}
MYCONF=$WORKDIR/.$BASE.conf
if [[ ! $MYCONF ]]; then
    printf '%s: Unable to find configuration file "%s"\n' "$0" "$MYCONF" >&2
    exit 1
fi

# Set defaults
DAYS=7

. "$MYCONF" || exit

for DIR in "${CACHEDIRS[@]}"; do
    if [[ -d $DIR ]]; then

        (
        # Remove old files
        find "$DIR/" \
            -mindepth 1 \
            -type f \
            ! -name .gitignore \
            -mtime "+$DAYS" \
            -print \
            -delete &&

        # Clear out any empty directories, including the cache dir itself
        find "$DIR/" \
            -type d \
            -empty \
            -print \
            -delete
        ) >>"$LOG" || exit

    fi
done
