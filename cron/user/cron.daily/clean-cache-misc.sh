#!/bin/bash
# vi: et sts=4 sw=4 ts=4

. ~/.cron/cron.conf

CACHEDIRS=(
# auto-generated thumbnails from geeqie, probably others
~/.thumbnails
# Steam crash dumps - whenever a game crashes Steam adds a file here
/tmp/dumps
~/.cache/youtube-dl
~/.cache/fontconfig
~/.cache/winetricks
)

DAYS=7

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
