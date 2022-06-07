#!/bin/bash
# vi: et sts=4 sw=4 ts=4

USAGE() {
    printf 'Usage: %s [OPTIONS] [--] FILE...\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Optimize image files for size.

  -h            Show this help message.
  -N            Do not normalize files before burning.
  -g SECONDS    Set the default pregap to 0 seconds.

Copyright (C) 2010 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
}

RECORDER='/dev/cdrom'

NORMALIZE=1
PREGAP=2
while getopts 'hNg:' FLAG; do
    case "$FLAG" in
        'N')
            NORMALIZE=0
            ;;
        'g')
            PREGAP=$OPTARG
            ;;
        'h')
            HELP_MESSAGE
            exit 0
            ;;
        *)
            printf 'Unrecognized flag: %s\n' \
                "$FLAG" \
                >&2
            USAGE >&2
            exit 1
            ;;
    esac
done

shift "$((OPTIND-1))"

TEMP_FILES=()

cleanup() {
    rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup' EXIT

CDRECORD_OPTS=(
    '-audio'
    "dev=$RECORDER"
    '-pad'
)

WAV_FILES=()

# CD specification
FFMPEG_OPTS=(
    '-ar'   '44100'
    '-ac'   '2'
    '-f'    'wav'
)

if [[ $PREGAP -ne 0 ]]; then
    CDRECORD_OPTS+=("defpregap=$PREGAP")
fi

# parse M3U file into a list of files
readarray -t FILES < <(
	grep -v '^#' "$1"
)

for AUDIO_FILE in "${FILES[@]}"; do
    OUT_WAV=$(mktemp -t "${0##*/}.XXXXXX")
    WAV_FILES+=("$OUT_WAV")
    TEMP_FILES+=("$OUT_WAV")
    # use mplayer to decode the sound file
    #mplayer -srate 44100 -ao pcm:file="$OUT_WAV").wav" "$OUT_WAV" || exit 1
    # addendum: mplayer does not always work, and ffmpeg is faster
    ffmpeg \
        -i "$AUDIO_FILE" \
        "${FFMPEG_OPTS[@]}" \
        "$OUT_WAV" || exit
done

if [[ $NORMALIZE -ne 0 ]] && type normalize &>/dev/null; then
    normalize "${WAV_FILES[@]}"
fi

cdrecord "${CDRECORD_OPTS[@]}" "${WAV_FILES[@]}"

# for good measure
cleanup
