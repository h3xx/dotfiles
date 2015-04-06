#!/bin/bash
# vi: et sts=4 sw=4 ts=4

HELP_MESSAGE() {
    local EXIT_CODE=${1:-0}
    cat <<EOF
Usage: ${0##*/} [OPTIONS] [XPM_FILE]...
Resize XPM icons to a given size.

  -h        Show this help message.
  -f        Force over-writing output files.
  -o DIR    Write new icons to [DIR]/[BASENAME].xpm. Default is \`.'.
  -s DIMS   New dimenstions in the format \`[PIXELS_X]x[PIXELS_Y]' or
          \`[PIXELS_X_AND_Y]' (for square images). Default is 12.

Copyright (C) 2010 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"
}

DIMS='12x12'
OUT_DIR='.'
FORCE=0

while getopts 'hs:o:f' flag; do
    case "$flag" in
        's')
            DIMS=$OPTARG
            ;;
        'o')
            OUT_DIR=$OPTARG
            ;;
        'f')
            FORCE=1
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

# determine x and y sizes
if [[ $DIMS == *[^0-9]* ]]; then
    # split dimension
    XSIZE=$(echo "$DIMS" |tr -c '[:digit:]' '\n' |head -1)
    YSIZE=$(echo "$DIMS" |tr -c '[:digit:]' '\n' |tail -1)
else
    # use as square dimension
    XSIZE=$DIMS
    YSIZE=$DIMS
fi

if [[ -z $YSIZE || -z $XSIZE ]]; then
    echo "error: invalid dimensions: \`$DIMS' (must contain a number)" >&2
    exit 1
fi

resize_xpm() {
    local \
        IN=$1 \
        OUT=$2 \
        XSIZE=$3 \
        YSIZE=$4 \
        ALPHA_TEMP \
        IMAGE_TEMP_R \
        ALPHA_TEMP_R \
        XPM_NAME

    ALPHA_TEMP=$(mktemp -t "${0##*/}.XXXXXX")
    IMAGE_TEMP_R=$(mktemp -t "${0##*/}.XXXXXX")
    ALPHA_TEMP_R=$(mktemp -t "${0##*/}.XXXXXX")

    TEMP_FILES+=(
        "$ALPHA_TEMP"
        "$IMAGE_TEMP_R"
        "$ALPHA_TEMP_R"
    )

    # determine the xpm's internal name
    XPM_NAME=$(basename -- "$OUT" |tr . _)

    # extract the alpha channel, scale the rest and save it
    xpmtoppm "$IN" --alphaout="$ALPHA_TEMP" |
    pnmscale \
        -xsize="$XSIZE" \
        -ysize="$YSIZE" >"$IMAGE_TEMP_R" &&

    # scale the alpha channel and save it
    pnmscale \
        -xsize="$XSIZE" \
        -ysize="$YSIZE" \
        "$ALPHA_TEMP" >"$ALPHA_TEMP_R" &&

    # glue the resized parts back together into an xpm
    ppmtoxpm \
        -name="$XPM_NAME" \
        -alphamask="$ALPHA_TEMP_R" \
        "$IMAGE_TEMP_R" >"$OUT"
}

[[ $# -ne 0 ]] || HELP_MESSAGE 2

# start resizing images
for XPM; do
    OUTNAME=$OUT_DIR/$(basename -- "$XPM")
    if [[ $FORCE -eq 0 && -e $OUTNAME ]]; then
        echo "output file \`$OUTNAME' already exists (force overwrite with -f)" >&2
    else
        resize_xpm \
            "$XPM" \
            "$OUTNAME" \
            "$XSIZE" \
            "$YSIZE"
    fi
done
