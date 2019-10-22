#!/bin/bash
# vi: sw=4 ts=4 sts=4 et

HELP_MESSAGE() {
    local EXIT_CODE="${1:-0}"
    cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--] FILE...
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

TEXT=''

while getopts 't:h' flag; do
    case "$flag" in
        'h')
            HELP_MESSAGE 0
            ;;
        't')
            TEXT="$OPTARG"
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

trap 'cleanup'  EXIT

fontimage_args=()

if [[ -n "$TEXT" ]]; then
    fontimage_args+=(--text "$TEXT")
fi

TEMP_DIR="$(mktemp -d -t "$(basename -- "$0").XXXXXX")"

for fn; do
    # XXX : fontimage requires .png extension
    temp="$TEMP_DIR/fontimage-$(basename -- "$fn").png"
    fontimage "${fontimage_args[@]}" -o "$temp" "$fn" || exit
done

geeqie "$TEMP_DIR"/*.png
