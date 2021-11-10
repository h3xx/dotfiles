#!/bin/bash
# vi: et sts=4 sw=4 ts=4

set -e

. ~/.cron/cron.conf

WORKDIR=${0%/*}
BASE=${0##*/}
MYCONF=$WORKDIR/.$BASE.conf
if [[ ! -f $MYCONF ]]; then
    printf '%s: Unable to find configuration file "%s"\n' "$0" "$MYCONF" >&2
    exit 1
fi

# Set defaults
DAYS=7
CLEAN_FILES=1
CLEAN_DIRS=1

. "$MYCONF"

for DIR in "${CACHEDIRS[@]}"; do
    if [[ -d $DIR ]]; then

        (

        # Fix permissions on directories
        find "$DIR/" \
            -type d \
            ! -perm /0200 \
            -exec chmod u+w -- {} +

        if [[ $CLEAN_FILES -ne 0 ]]; then
            # Remove old files
            find "$DIR/" \
                -mindepth 1 \
                -type f \
                ! -name .gitignore \
                -mtime "+$DAYS" \
                -print \
                -delete
        fi

        if [[ $CLEAN_DIRS -ne 0 ]]; then
            # Clear out any empty directories, including the cache dir itself
            find "$DIR/" \
                -type d \
                -empty \
                -print \
                -delete
        fi

        ) >>"$LOG"

    fi
done
