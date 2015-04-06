#!/bin/sh
# vi: et sts=4 sw=4 ts=4

HELP_MESSAGE() {
    local EXIT_CODE=${1:-0}
    cat <<EOF
Usage: ${0##*/} [OPTIONS] [--] FILE...
Check over your fluxbox menu file for missing binaries.

  -i FILE   Use FILE as menu. Default is ~/.fluxbox/menu.
  -h        Show this help message.
  --        Terminate options list.

Copyright (C) 2014 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"
}

MENU=~/.fluxbox/menu

while getopts 'hi:' flag; do
    case "$flag" in
        'i')
            MENU=$OPTARG
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

for BINNAME in $(
cat "$MENU" |
# -n = no output unless /p which means print if match
# 1: strip comments
# 2: find first word of program name
sed -n '
    s,#.*$,,;
    s,.*\[exec\].*{(*\([^ ;}]*\)\}.*$,\1,p
'
) ; do
    which "$BINNAME" >/dev/null 2>&1 || echo "$BINNAME not found"
done
