#!/bin/bash

while getopts 'a:r:f:t:n:d:D:h' flag; do
	case "$flag" in
        a)
            ARTIST="$OPTARG"
            ;;
        r)
            ALBUM="$OPTARG"
            ;;
        f)
            FILENAME="$OPTARG"
            ;;
        t)
            TITLE="$OPTARG"
            ;;
        n)
            TRACK_NUM="$OPTARG"
            ;;
        d)
            DUR_HR="$OPTARG"
            ;;
        D)
            DUR_SECONDS="$OPTARG"
            ;;
		*)
            echo "Bad option \`-$flag'" >&2
            exit 2
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
