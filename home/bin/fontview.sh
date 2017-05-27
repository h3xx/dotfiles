#!/bin/bash
# vi: et sts=4 sw=4 ts=4

USAGE() {
    printf 'Usage: %s [OPTIONS] [--] FILE...\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Display an image of a font file.

  -h        Show this help message.
  -t TEXT   Show TEXT instead of default.
  --        Terminate options list.

Copyright (C) 2015-2019 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
}

TEXT=

while getopts 't:h' FLAG; do
    case "$FLAG" in
        't')
            TEXT=$OPTARG
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

if [[ $# -eq 0 ]]; then
    USAGE
    exit 2
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

xv "$TEMP_DIR"/*.png
