#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# uses imagemagick's import(1) utility to take a screenshot of the current
# window

HELP_MESSAGE() {
    local EXIT_CODE=${1:-0}
    cat <<EOF
Usage: ${0##*/} [OPTIONS] [FILE]...
Take a quick screenshot and save it to a file.

  -h            Show this help message.
  -d SECONDS    Wait this long before taking a screenshot.
  -a            Take a screenshot of the entire desktop.
  -w            Take a screenshot of a single window including frame (default).
  -v            Verbose output.
  -O            Optimize the output file using pngcrush(1) or optipng(1).

By default, the screenshot is output to ./screenshot-YYYY-MMDD-HHMM[-?].png,
otherwise it/they will be output to FILE.

Copyright (C) 2010 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"
}

ROOT_WINDOW=0
VERBOSE=0
DELAY=0
OPTIMIZE=0

while getopts 'd:awvOh' flag; do
    case "$flag" in
        'd')
            DELAY=$OPTARG
            ;;
        'a')
            ROOT_WINDOW=1
            ;;
        'w')
            ROOT_WINDOW=0
            ;;
        'v')
            VERBOSE=1
            ;;
        'O')
            OPTIMIZE=1
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

choose_output() {
    local \
        IMAGE_SUFFIX='.png' \
        IMAGE_BASE="screenshot-$(date '+%Y-%m%d-%H%M')" \
        IMAGE_OUT \
        DUP_CT=0

    IMAGE_OUT=$IMAGE_BASE$IMAGE_SUFFIX

    # find a non-existant place to put the image
    while [[ -e $IMAGE_OUT ]]; do
        let ++DUP_CT
        IMAGE_OUT=${IMAGE_BASE}-${DUP_CT}$IMAGE_SUFFIX
    done

    echo "$IMAGE_OUT"
}

optimize_image() {
    local \
        IMAGE \
        MIMETYPE \
        ORIGSIZE \
        NEWSIZE \
        TEMP_OUT

    for IMAGE; do

        TEMP_OUT=$(mktemp -t "${0##*/}.XXXXXX")

        MIMETYPE=$(file --brief --mime-type -- "$IMAGE")
        ORIGSIZE=$(($(stat -c %s -- "$IMAGE" 2>/dev/null)+0))

        case "$MIMETYPE" in
            'image/png')
                if hash optipng &>/dev/null; then
                    # optipng refuses to overwrite files
                    rm -f -- "$TEMP_OUT"
                    optipng \
                        -fix \
                        -force \
                        -preserve \
                        -out "$TEMP_OUT" \
                        -- \
                        "$IMAGE"
                elif hash pngcrush &>/dev/null; then
                    # note: pngcrush can't handle input
                    # files starting with `-'
                    pngcrush \
                        -q \
                        -brute "$IMAGE" \
                        "$TEMP_OUT"
                fi
                ;;
            'image/jpeg')
                # note: jpegtran and jhead can't handle input
                # files starting with `-'
                jpegtran \
                    -optimize \
                    -outfile "$TEMP_OUT" \
                    "$IMAGE" &&

                # copy EXIF information from original
                # file to the temporary file
                jhead \
                    -te "$TEMP_OUT" \
                    "$IMAGE"
                ;;
            *)
                echo "image type of \`$image_file' not recognized" >&2
                ;;
        esac
        NEWSIZE=$(($(stat -c %s -- "$TEMP_OUT" 2>/dev/null)+0))
        if [[ $NEWSIZE -gt 0 && $NEWSIZE -lt $ORIGSIZE ]]; then
            touch --reference="$IMAGE" -- "$TEMP_OUT"
            chmod --reference="$IMAGE" -- "$TEMP_OUT"
            if [[ $UID -eq 0 ]]; then
                # we're root
                chown --reference="$IMAGE" -- "$TEMP_OUT"
            fi

            # copy the image over the new one
            cp -p -- "$TEMP_OUT" "$IMAGE"
        fi

        rm -f -- "$TEMP_OUT"
    done
}

OUTPUTS=("$@")

if [[ ${#OUTPUTS[@]} -eq 0 ]]; then
    OUTPUTS+=("$(choose_output)")
fi

IMPORT_OPTS=(
    '-quality' '9'  # JPEG/MIFF/PNG compression level
)

if [[ $ROOT_WINDOW -ne 0 ]]; then
    IMPORT_OPTS+=(
        '-screen' # select image from root window
    )
fi

if [[ $VERBOSE -ne 0 ]]; then
    IMPORT_OPTS+=(
        '-verbose' # print detailed information about the image
        '-monitor' # monitor progress
    )
fi

for IMAGE_OUT in "${OUTPUTS[@]}"; do
    sleep "$DELAY"
    import "${IMPORT_OPTS[@]}" "$IMAGE_OUT"
done

# finisher: optimize images for size
if [[ $OPTIMIZE -ne 0 ]]; then
    for IMAGE_OUT in "${OUTPUTS[@]}"; do
        if [[ -f $IMAGE_OUT ]]; then
            optimize_image "$IMAGE_OUT"
        fi
    done
fi
