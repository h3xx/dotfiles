#!/bin/sh
# vi: et sts=4 sw=4 ts=4

USAGE() {
    printf 'Usage: %s [OPTIONS] [--] FILE...\n' \
        "${0##*/}" \
        >&2
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Check over your fluxbox menu file for missing binaries.

  -i FILE   Use FILE as menu. Default is ~/.fluxbox/menu.
  -h        Show this help message.
  --        Terminate options list.

Copyright (C) 2014-2022 Dan Church.
License GPLv3: GNU GPL version 3.0 (https://www.gnu.org/licenses/gpl-3.0.html)
with Commons Clause 1.0 (https://commonsclause.com/).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
You may NOT use this software for commercial purposes.
EOF
}

MENU=~/.fluxbox/menu

while getopts 'hi:' FLAG; do
    case "$FLAG" in
        'i')
            MENU=$OPTARG
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

for BINNAME in $(
# -n = no output unless /p which means print if match
# 1: strip comments
# 2: find first word of program name
sed -n '
    s,#.*$,,;
    s,.*\[exec\].*{(*\([^ ;}]*\)\}.*$,\1,p
' < "$MENU"
) ; do
    if ! type "$BINNAME" &>/dev/null; then
        printf '%s not found\n' \
            "$BINNAME" \
            >&2
    fi
done
