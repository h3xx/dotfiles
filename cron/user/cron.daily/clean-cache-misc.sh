#!/bin/bash

. ~/.cron/cron.conf

CACHEDIRS=(
# auto-generated thumbnails from geeqie, probably others
~/.thumbnails
# Steam crash dumps - whenever a game crashes Steam adds a file here
/tmp/dumps
~/.cache/youtube-dl
~/.cache/fontconfig
~/.cache/winetricks
)

DAYS=7

for dir in "${CACHEDIRS[@]}"; do
	if [[ -d $dir ]]; then

		# remove old files
		(
		find "$dir/" \
			-mindepth 1 \
			-type f \
			! -name .gitignore \
			-mtime "+$DAYS" \
			-print \
			-delete &&

		# clear out any empty directories, including the cache dir
		# itself
		find "$dir/" \
			-type d \
			-empty \
			-print \
			-delete
		) >>"$LOG" || exit

	fi
done
