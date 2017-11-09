#!/bin/bash
# vi: sw=4 ts=4 sts=4 et

HELP_MESSAGE() {
        local EXIT_CODE="${1:-0}"
        cat <<EOF
Usage: $(basename -- "$0") [OPTIONS]
List postgresql databases

  -h            Show this help message.
  -l            List extra info about the database.
  -U USER       Log into the cluster using USER.

Copyright (C) 2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
        exit "$EXIT_CODE"
}

LONG=0
USER=postgres
while getopts 'hU:l' flag; do
    case "$flag" in
        'l')
            LONG=1
            ;;
        'U')
            USER=$OPTARG
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
    "
fi

exec psql --expanded -U "$USER" postgres -c "$LIST_CMD"
