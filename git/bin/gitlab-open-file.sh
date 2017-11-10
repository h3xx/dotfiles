#!/bin/bash

# target: https://git.g2planet.com/g2planet/qualcomm-qualcommsummit2015/blob/master/php/page/RegStart.php#L296

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--]
Open a web browser to Gitlab to a file.

  -h		Show this help message.
  -s BRANCH	Set source branch (defaults to current branch).
  -l LINE   Jump to line.
  --		Terminate options list.

Copyright (C) 2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"

}

SOURCE_BRANCH=''
LINE=''
while getopts 'hs:l:' flag; do
	case "$flag" in
		's')
			SOURCE_BRANCH="$OPTARG"
			;;
        'l')
            LINE=$OPTARG
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

if [[ -z $SOURCE_BRANCH ]]; then
	SOURCE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
	if [[ -z $SOURCE_BRANCH ]]; then
		echo "Unable to determine current branch (are you in a git directory?)"
		exit 2
	fi
fi

#get full path rel to project root
# git ls-files --full-name $FILE


# construct URL

FILE=$1

# first, change directory back to where we were when we called the script
cd "$GIT_PREFIX" || exit
full_path="$(git ls-files --full-name "$FILE")"
push_url="$(git remote -v |sed -e 's#^'"$(git config "branch.$SOURCE_BRANCH.remote")"'\s*\(.*\)\s*(push)$#\1# p;d')"
http_url="$(echo $push_url |perl -p -e ' s#^ssh://##; s#:\d+/#/#; if (m#^\w*@#) { s#:#/#g; s#^\w*@#https://#; } s#\.git$##;')"
# XXX : NOT url-escaped shashes
file_view_url="$http_url/blob/$SOURCE_BRANCH/$full_path"

if [[ ! -z $LINE ]]; then
    file_view_url+="#L$LINE"
fi

google-chrome "$file_view_url"
