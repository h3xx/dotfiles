#!/bin/bash
# vi: sw=4 ts=4 sts=4 et

HELP_MESSAGE() {
        local EXIT_CODE="${1:-0}"
        cat <<EOF
Usage: $(basename -- "$0") [OPTIONS]
List postgresql databases

  -b            Bare database listing.
  -h            Show this help message.
  -l            List extra info about the database.
  -S            Order by size.
  -r            Reverse order.
  -U USER       Log into the cluster using USER.

Copyright (C) 2017-2020 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
        exit "$EXIT_CODE"
}

BARE=0
LONG=0
ORDER_COL='datname'
ORDER_DIR='asc'
USER=postgres
while getopts 'hbU:Srl' flag; do
    case "$flag" in
        'b')
            BARE=1
            LONG=0
            ;;
        'l')
            LONG=1
            BARE=0
            ;;
        'U')
            USER=$OPTARG
            ;;
        'S')
            ORDER_COL='pg_catalog.pg_database_size(datname)'
            ;;
        'r')
            ORDER_DIR='desc'
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

if [[ $LONG -ne 0 ]]; then
    LIST_CMD="
        select
            datname,
            pg_size_pretty(pg_catalog.pg_database_size(datname)) as size
        from
            pg_database
        where
            datname not in (
                'postgres'
            )
            and datistemplate = 'f'
        order by
            $ORDER_COL $ORDER_DIR
    "
else
    LIST_CMD="
        select
            datname
        from
            pg_database
        where
            datname not in (
                'postgres'
            )
            and datistemplate = 'f'
        order by
            $ORDER_COL $ORDER_DIR
    "
fi

if [[ $BARE -ne 0 ]]; then
    LIST_CMD="copy ($LIST_CMD) to stdout"
fi

exec psql --expanded -U "$USER" postgres -c "$LIST_CMD"
