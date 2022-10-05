#!/bin/bash
# vi: sw=4 ts=4 sts=4 et

USAGE() {
    printf 'Usage: %s [OPTIONS]\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
List postgresql databases

  -b                    Bare database listing.
  -h,--help             Show this help message.
  -l                    List extra info about the database.
  -S                    Order by size.
  -r                    Reverse order.
  -U USER,--user=USER   Log into the cluster using USER.

Copyright (C) 2017-2022 Dan Church.
License GPLv3: GNU GPL version 3.0 (https://www.gnu.org/licenses/gpl-3.0.html)
with Commons Clause 1.0 (https://commonsclause.com/).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
You may NOT use this software for commercial purposes.
EOF
}

BARE=0
LONG=0
ORDER_COL='x.name'
ORDER_DIR='asc'
USER=postgres

NO_MORE_FLAGS=0
for ARG; do
    if [[ $(type -t ASSIGN_NEXT 2>/dev/null) = 'function' ]]; then
        ASSIGN_NEXT "$ARG"
        unset ASSIGN_NEXT
        continue
    fi
    # Assume arguments that don't begin with a - are supposed to be files or other operands
    if [[ $NO_MORE_FLAGS -eq 0 && $ARG = -* ]]; then
        case "$ARG" in
            -b)
                BARE=1
                LONG=0
                ;;
            -l)
                LONG=1
                BARE=0
                ;;
            -r)
                ORDER_DIR='desc'
                ;;
            -S)
                ORDER_COL='x.size_bytes'
                ;;
            -U)
                ASSIGN_NEXT() {
                    USER=$1
                }
                ;;
            --user=*)
                USER=${ARG#*=}
                ;;
            --help|-h)
                HELP_MESSAGE
                exit 0
                ;;
            --)
                NO_MORE_FLAGS=1
                ;;
            *)
                printf 'Unrecognized flag: %s\n' \
                    "$ARG" \
                    >&2
                USAGE >&2
                exit 2
                ;;
        esac
    fi
done

# List databases and sizes
INNER_LIST_CMD="
    select
        datname as name,
        pg_catalog.pg_database_size(datname) as size_bytes
    from
        pg_database
    where
        datname not in (
            'postgres'
        )
        and datistemplate = 'f'
"
if [[ $LONG -ne 0 ]]; then
    LIST_CMD="
        select name, pg_size_pretty(size_bytes) as size
    "
else
    LIST_CMD="
        select name
    "
fi
LIST_CMD+="
    from ($INNER_LIST_CMD) x
    order by
        $ORDER_COL $ORDER_DIR
"

if [[ $BARE -ne 0 ]]; then
    LIST_CMD="copy ($LIST_CMD) to stdout"
fi

exec psql --expanded -U "$USER" postgres -c "$LIST_CMD"
