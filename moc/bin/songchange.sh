#!/bin/bash
# vi: et sts=4 sw=4 ts=4

ARTIST=
ALBUM=
FILENAME=
TITLE=
TRACK_NUM=
DUR_HR=
DUR_SECONDS=

while getopts 'a:r:f:t:n:d:D:h' FLAG; do
    case "$FLAG" in
        a)
            ARTIST=$OPTARG
            ;;
        r)
            ALBUM=$OPTARG
            ;;
        f)
            FILENAME=$OPTARG
            ;;
        t)
            TITLE=$OPTARG
            ;;
        n)
            TRACK_NUM=$OPTARG
            ;;
        d)
            DUR_HR=$OPTARG
            ;;
        D)
            DUR_SECONDS=$OPTARG
            ;;
        *)
            printf 'Unrecognized flag: %s\n' \
                "$FLAG" \
                >&2
            exit 1
            ;;
    esac
done

shift "$((OPTIND-1))"

# step 1: Pop up toaster notification

notify-send \
    --app-name=mocp \
    --urgency=low \
    "$ARTIST - $TITLE"

# step 2: Submit scrobble to Last.FM

~/bin/lastfm-submit \
    -a "$ARTIST" \
    -b "$ALBUM" \
    -t "$TITLE" \
    -n "$TRACK_NUM" \
    -d "$DUR_HR"
