#!/bin/bash

. "$0.conf"

if [[ -z $GITLAB_API_URL || -z $GITLAB_TOKEN ]]; then
    printf 'Must specify GITLAB_TOKEN and GITLAB_API_URL in %s\n' "$0.conf" >&2
    exit 2
fi

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] REMOTE BRANCH... [--]
Unprotect branch.

  -h		Show this help message.
  -p PROJ   Set project name (will try to determine it if unspecified)
  -d        Delete branch via API too.
  --		Terminate options list.

Copyright (C) 2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"

}

PROJ=''
DELETE=0

while getopts 'hp:d' flag; do
	case "$flag" in
		'p')
			PROJ="$OPTARG"
			;;
		'd')
			DELETE=1
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

url_encode() {
    perl -MURI::Escape -e 'print &uri_escape($_), "\n" foreach @ARGV' "$@"
}

callGitlabAPI() {
    local \
        method="$1" \
        resource="$2" \
        jsonData="$3" \
        filter="$4"

    if [[ -z "$filter" ]]; then
        filter="."
    fi

    echo $GITLAB_API_URL/$resource >&2
    curl \
        -s \
        -H "Content-Type: application/json" \
        -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        -d "$jsonData"\
        -X $method \
        $GITLAB_API_URL/$resource | jq "$filter"

    # note: for pulling pieces of API data out, pipe thru jq:
    #jq "$filter"

}

unprotect_branch() {
    local \
        project="$1" \
        branch="$2"
    local api_url="$project/repository/branches/$branch/unprotect"
    echo "Calling API: $api_url"

    callGitlabAPI PUT "$api_url" ''
}

delete_branch() {
    local \
        project="$1" \
        branch="$2"
    local api_url="$project/repository/branches/$branch"

    callGitlabAPI DELETE "$api_url" ''
}

get_remote_url() {
    git config "remote.$1.url"
}

REMOTE="$1"

if [[ -z "$REMOTE" ]]; then
    printf 'Remote not specified\n' >&2
    exit 2
fi

# detect project name
if [[ -z "$PROJ" ]]; then
    # different URL schemes:
    # - ssh://git@git.g2planet.com:8044/g2planet/eclib.git
    # - git@git.g2planet.com:g2planet/eclib.git
    # - https://git.g2planet.com/g2planet/eclib.git
    remote_url="$(get_remote_url "$REMOTE"|tr : /)"
    PROJ="$(basename -- "$(dirname -- "$remote_url")")/$(basename -- "$remote_url" .git)"
    printf 'Project name determined to be %s\n' "$PROJ"
fi

if [[ -z "$PROJ" ]]; then
    printf 'Unable to determine project for remote %s.\n' "$REMOTE" >&2
    printf 'Try setting it using -p\n' >&2
    exit 2
fi

shift 1

proj="$(url_encode "$PROJ")"
for branch; do
    unprotect_branch "$proj" "$(url_encode "$branch")"
    if [[ $DELETE -ne 0 ]]; then
        delete_branch "$proj" "$(url_encode "$branch")"
    fi
done
