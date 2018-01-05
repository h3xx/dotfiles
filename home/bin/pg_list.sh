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

  -h            Show this help message.
  -l            List extra info about the database.
  -U USER       Log into the cluster using USER.

Copyright (C) 2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
}

LONG=0
USER=postgres
while getopts 'hU:l' FLAG; do
    case "$FLAG" in
        'l')
            LONG=1
            ;;
        'U')
            USER=$OPTARG
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

# List databases and sizes
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
            datname
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
            datname
    "
fi

exec psql --expanded -U "$USER" postgres -c "$LIST_CMD"
