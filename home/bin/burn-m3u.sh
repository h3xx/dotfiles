#!/bin/sh
# vi: et sts=4 sw=4 ts=4
HELP_MESSAGE() {
    local EXIT_CODE=${1:-0}
    cat <<EOF
Usage: ${0##*/} [OPTIONS] [--] FILE...
Optimize image files for size.

  -h            Show this help message.
  -N            Do not normalize files before burning.
  -g SECONDS    Set the default pregap to 0 seconds.

Copyright (C) 2010 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"
}
TEMP='/tmp'
RECORDER='/dev/cdrom'

NORMALIZE=1
PREGAP=2
while getopts 'hNg:' flag; do
    case "$flag" in
        'N')
            NORMALIZE=0
            ;;
        'g')
            PREGAP=$OPTARG
            ;;
        'h')
            HELP_MESSAGE 0
            ;;
        *)
            HELP_MESSAGE 1
            ;;
    esac
done

shift "$((OPTIND-1))"

TEMP_FILES=()

cleanup() {
    rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup' EXIT

cdrecord_opts=(
    '-audio'
    "dev=$RECORDER"
    '-pad'
)

wav_files=()

# CD specification
ffmpeg_opts=(
    '-ar'   '44100'
    '-ac'   '2'
    '-f'    'wav'
)

if [ "$PREGAP" -ne 0 ]; then
    cdrecord_opts+=("defpregap=$PREGAP")
fi

# parse M3U file into a list of files
eval files=($(grep -v '^#' "$1" | sed -e 's/"/\\\\"/g; s/^/"/; s/$/"/'))

for audio_file in "${files[@]}"; do
    out_wav="$(mktemp -t "$(basename "$0").XXXXXX")"
    wav_files+=("$out_wav")
    TEMP_FILES+=("$out_wav")
    # use mplayer to decode the sound file
    #mplayer -srate 44100 -ao pcm:file="$out_wav").wav" "$out_wav" || exit 1
    # addendum: mplayer does not always work, and ffmpeg is faster
    ffmpeg \
        -i "$audio_file" \
        "${ffmpeg_opts[@]}" \
        "$out_wav" || exit
done

if [ "$NORMALIZE" -ne 0 ] && which normalize >/dev/null 2>&1; then
    normalize "${wav_files[@]}"
fi

cdrecord "${cdrecord_opts[@]}" "${wav_files[@]}"

# for good measure
cleanup
