#!/bin/bash

ARTIST=""
ALBUM=""
FILENAME=""
TITLE=""
TRACK_NUM=""
DUR_HR=""
DUR_SECONDS=""

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

NOTIFY_DISP=''
for notify_piece in \
	"$ARTIST" \
	"$TITLE" \
	; do
	if [[ -n "$notify_piece" ]]; then
		NOTIFY_DISP="${NOTIFY_DISP:+ - }$notify_piece"
	fi
done

if [[ -n $NOTIFY_DISP ]]; then
	notify-send \
		--app-name=mocp \
		--urgency=low \
		"$ARTIST - $TITLE"
fi

# step 2: Submit scrobble to Last.FM

~/bin/lastfm-submit \
    -a "$ARTIST" \
    -b "$ALBUM" \
    -t "$TITLE" \
    -n "$TRACK_NUM" \
    -d "$DUR_HR"
