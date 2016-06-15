#!/bin/bash
# delete old vim view files

AGE=60 # days

SEARCH_DIRS=(
	~/.vim/view
	~/.vim/temp
)

for dir in "${SEARCH_DIRS[@]}"; do
	if [ -d "$dir" ]; then
		find "$dir" \
			-maxdepth 1 \
			-mindepth 1 \
			-type f \
			! -name .gitignore \
			-mtime "+$AGE" \
			-delete 2>/dev/null
	fi
done
