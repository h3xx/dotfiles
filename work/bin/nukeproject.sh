#!/usr/bin/env bash

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") PROJECT
Nuke a project on the current server.

Copyright (C) 2015 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

project="$1"
server_name="$(uname -n)"

if [[ -z "$project" ]]; then
	HELP_MESSAGE 2
fi

read -p "Are you sure you want to nuke project $project on server $server_name? [type uppercase YES] " confirm

if [[ "_$confirm" != '_YES' ]]; then
	echo "Alrighty then."
	exit 1
fi

cat <<'EOF'
                             ____
                     __,-~~/~    `---.
                   _/_,---(      ,    )
               __ /        <    /   )  \___
- ------===;;;'====------------------===;;;===----- -  -
                  \/  ~"~"~"~"~"~\~"~)~"/
                  (_ (   \  (     >    \)
                   \_( _ <         >_>'
                      ~ `-i' ::>|--"
                          I;|.|.|
                         <|i::|i|`.
                        (` ^'"`-' ")
------------------------------------------------------------------
                                                        Bill March
EOF

psql -U pgsql postgres -c "drop database $project;"
psql -U pgsql postgres -c "drop user $project;"

sudo rm -rf /usr/local/{www/data,g2planet}/$project
