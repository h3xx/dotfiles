#!/bin/bash
# delete old compiled templates

AGE=60 # days

SEARCH_DIRS=(
	~/public_html
)

for dir in "${SEARCH_DIRS[@]}"; do
	if [ -d "$dir" ]; then

        # make sure permissions are correct
		find "$dir/" \
            -type d \
            -name templates_c \
            ! -user $USER \
            -exec sudo chown $USER {} + \
            >/dev/null 2>&1

		find "$dir/" \
            -type d \
            -name templates_c \
            -exec chmod 1777 {} + \
            >/dev/null 2>&1

        # clear old files
		find "$dir/" \
			-mindepth 1 \
			-type f \
			-regextype posix-egrep \
			-regex '.*/templates_c/.*\.php' \
			-mtime "+$AGE" \
			-delete

	fi
done
