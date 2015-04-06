#!/bin/bash
# vi: et sts=4 sw=4 ts=4

USAGE() {
    printf 'Usage: %s PNG [NAME]\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    cat <<EOF
Add an icon for the Fluxbox menu, automatically resizing.

PNG is the input icon file.
NAME is the name of the .xpm file for output.

Copyright (C) 2012-2013 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
}

TEMP_FILES=()

cleanup() {
    rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup'  EXIT

ICON_X=${ICON_X:-12}
ICON_Y=${ICON_Y:-$ICON_X}
ICON_FS_DIR="$HOME/.fluxbox/icons-fullsize"
ICON_DIR="${ICON_DIR:-$HOME/.fluxbox/icons-${ICON_X}x${ICON_Y}}"

file_size() {
    # adds all the file sizes by doing a stat on all of them (separated by
    # `\n'), transforming them into `LINE+LINE+...LINE+0' and passing them
    # to the Bash expression evaluator
    echo "$(($(
        stat \
            --format='%s' \
            --dereference \
            -- \
            "$@" 2>/dev/null |
        tr '\n' '+'
    )0))"
}

img_to_pnm() {
    local \
        IN=$1 \
        OUT=$2 \
        OUT_ALPHA=$3 \
        IN_MIME

    IN_MIME=$(file --mime-type --brief -- "$IN")
    IN_MIME_LONG=$(file --brief -- "$IN")

    case "$IN_MIME" in

        'image/png')
            pngtopnm -alpha "$IN" >"$OUT_ALPHA" &&
            pngtopnm "$IN" >"$OUT" ||
            return
            ;;

        'image/gif')
            giftopnm --alphaout="$OUT_ALPHA" "$IN" >"$OUT" ||
            return
            ;;

        'text/x-c')
            [[ $IN_MIME_LONG = 'X pixmap image text' ]] &&
            xpmtoppm --alphaout="$OUT_ALPHA" "$IN" >"$OUT" ||
            return
            ;;

        *)
            echo "Image type \`$IN_MIME' not supported." >&2
            return 1
            ;;
    esac
}

pnm_to_xpm() {
    local \
        IN=$1 \
        IN_ALPHA=$2 \
        OUT=$3 \
        XPM_NAME=$4

    if [[ -z $XPM_NAME ]]; then
        XPM_NAME=$(basename -- "$OUT" |tr '.-' '__')
    fi

    if [[ -f $IN_ALPHA && $(file_size "$IN_ALPHA") -gt 0 ]]; then
        # has an alpha layer
        ppmtoxpm \
            -alphamask="$IN_ALPHA" \
            -name="$XPM_NAME" \
            "$IN" >"$OUT" ||
        return
    else
        ppmtoxpm \
            -name="$XPM_NAME" \
            "$IN" >"$OUT" ||
        return
    fi
}

resize_pnm() {
    local \
        IN=$1 \
        IN_ALPHA=$2 \
        OUT=$3 \
        OUT_ALPHA=$4 \
        XSIZE=$5 \
        YSIZE=$6

    pnmscale \
        -xsize="$XSIZE" \
        -ysize="$YSIZE" \
        "$IN" >"$OUT" ||
    return

    if [[ -f $IN_ALPHA && $(file_size "$IN_ALPHA") -gt 0 ]]; then
        # has an alpha layer
        pnmscale \
            -xsize="$XSIZE" \
            -ysize="$YSIZE" \
            "$IN_ALPHA" >"$OUT_ALPHA" ||
        return
    fi

}

convert_img_xpm() {
    local \
        IN=$1 \
        OUT=$2 \
        XSIZE=${3:-0} \
        YSIZE=${4:-0} \
        ALPHA_TEMP \
        IMAGE_TEMP \
        IMAGE_TEMP_R \
        ALPHA_TEMP_R \
        XPM_NAME

    XPM_NAME=$(basename -- "$OUT" |tr '.-' '__')

    ALPHA_TEMP=$(mktemp -t "${0##*/}.XXXXXX")
    IMAGE_TEMP=$(mktemp -t "${0##*/}.XXXXXX")
    IMAGE_TEMP_R=$(mktemp -t "${0##*/}.XXXXXX")
    ALPHA_TEMP_R=$(mktemp -t "${0##*/}.XXXXXX")

    TEMP_FILES+=(
        "$ALPHA_TEMP"
        "$IMAGE_TEMP"
        "$IMAGE_TEMP_R"
        "$ALPHA_TEMP_R"
    )

    img_to_pnm \
        "$IN" \
        "$IMAGE_TEMP" "$ALPHA_TEMP" ||
    return

    if [[ $XSIZE -gt 0 && $YSIZE -gt 0 ]]; then
        resize_pnm \
            "$IMAGE_TEMP" "$ALPHA_TEMP" \
            "$IMAGE_TEMP_R" "$ALPHA_TEMP_R" \
            "$XSIZE" "$YSIZE" ||
        return
    else
        cat -- "$IMAGE_TEMP" >"$IMAGE_TEMP_R" &&
        cat -- "$ALPHA_TEMP" >"$ALPHA_TEMP_R" ||
        return
    fi

    pnm_to_xpm \
        "$IMAGE_TEMP_R" "$ALPHA_TEMP_R" \
        "$OUT" \
        "$XPM_NAME" ||
    return
}

add_icon() {
    local \
        FROM_IMG=$1 \
        NAME=$2 \
        IN_MIME \
        FULLSIZE \
        SMALL

    if [[ -z $NAME ]]; then
        NAME=$(basename -- "${FROM_IMG%.*}")
        echo "Using name \`$NAME'" >&2
    fi

    FULLSIZE=$ICON_FS_DIR/$NAME.xpm
    SMALL=$ICON_DIR/$NAME.xpm

    # (not specifying the XSIZE and YSIZE will yield an unscaled XPM)
    echo "Writing full size image to \`$FULLSIZE'" >&2
    convert_img_xpm \
        "$FROM_IMG" "$FULLSIZE" &&

    echo "Writing ${ICON_X}x${ICON_Y} image to \`$SMALL'" >&2 &&
    convert_img_xpm \
        "$FROM_IMG" "$SMALL" \
        "$ICON_X" "$ICON_Y"
}

if [[ $# -lt 1 ]]; then
    USAGE
    exit 1
fi

add_icon "$@"
