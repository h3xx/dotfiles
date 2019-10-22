#!/bin/bash
# vi: et sts=4 sw=4 ts=4

HELP_MESSAGE() {
    local EXIT_CODE=${1:-0}
    cat <<EOF
Usage: ${0##*/} [OPTIONS] [--] FILE...
Display an image of a font file.

  -h        Show this help message.
  -t TEXT   Show TEXT instead of default.
  --        Terminate options list.

Copyright (C) 2015-2019 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"
}

TEXT=

while getopts 't:h' flag; do
    case "$flag" in
        'h')
            HELP_MESSAGE 0
            ;;
        't')
            TEXT=$OPTARG
            ;;
        *)
            HELP_MESSAGE 1
            ;;
    esac
done

shift "$((OPTIND-1))"

if [[ $# -eq 0 ]]; then
    HELP_MESSAGE 2
fi

cleanup() {
    rm -rf -- "$TEMP_DIR"
}

trap 'cleanup' EXIT

FONTIMAGE_ARGS=()

if [[ -n $TEXT ]]; then
    FONTIMAGE_ARGS+=(--text "$TEXT")
fi

TEMP_DIR=$(mktemp -d -t "${0##*/}.XXXXXX")

for FN; do
    # XXX : fontimage requires .png extension
    TEMP=$TEMP_DIR/fontimage-${FN##*/}.png
    fontimage "${FONTIMAGE_ARGS[@]}" -o "$TEMP" "$FN" || exit
done

geeqie "$TEMP_DIR"/*.png
