#!/usr/bin/env bash

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] DATABASE TABLE
Dump a full database table as a YAML record.

  -h		Show this help message.
  -i		Include id field.
  -o FIELD	Omit fields named FIELD.
  --		Terminate options list.

Copyright (C) 2014 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

OMIT_ID=1
while getopts 'hio:' flag; do
	case "$flag" in
		'o')
			OMITS+=("$OPTARG")
			;;
		'i')
			OMIT_ID=0
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

if [ "$#" -lt 2 ]; then
	HELP_MESSAGE 2
fi

if [ "_$OMIT_ID" == '_1' ]; then
	OMITS+=("$(echo "${2}" |egrep -o '^\w+' |head -1)_id")
fi

echo '---'

# get records in extended (-x) format
# (example:
#-[ RECORD 37 ]--------+-------------------
#event_type_id         | 223
#event_type            | Advisory Council
#color_name            | 
#color_rgb             | 
#tab_group             | Active
#create_time           | 
#creator_person_id     | 
#update_time           | 
#last_update_person_id | 
# )
psql -x -U "$1" -c "select * from $2" |
(
# omit fields if wanted
if [ "${#OMITS[@]}" -gt 0 ]; then
	egrep -v "($(IFS='|';echo "${OMITS[*]}"))"
else
	cat
fi
) |
# omit empty fields
(
perl -pe 's,^\w+\s+\| \n,,'
) |
# transform into YAML-esque records
perl -pe 's/^[^-]/ $&/;s/^-\[ RECORD.*-\n/\n-/;' |
# further indentation
perl -pe 's,^ ,  ,;s,\s+\| ,: ,'

echo '...'
