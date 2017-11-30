#!/bin/bash

. "$0.conf"

if [[ -z $GITLAB_API_URL || -z $GITLAB_TOKEN ]]; then
    printf 'Must specify GITLAB_TOKEN and GITLAB_API_URL in %s\n' "$0.conf" >&2
    exit 2
fi

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--]

  -i FILE   Read PR URL's from FILE. Default is "-" which denotes STDIN. Can be
              specified multiple times.
  -h        Show this help message.
  --        Terminate options list.

Copyright (C) 2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"

}

IN_FILES=()

while getopts 'i:h' flag; do
	case "$flag" in
		'i')
            IN_FILES+=("$OPTARG")
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

if [[ ${#IN_FILES[@]} -lt 1 ]]; then
    IN_FILES=('-')
fi


url_encode() {
    perl -MURI::Escape -e 'print &uri_escape($_), "\n" foreach @ARGV' "$@"
}

print_colored() {
    perl -MTerm::ANSIColor -e 'print &colored(@ARGV), "\n"' "$@"
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

report_pr_state() {
    local \
        project="$1" \
        pr_num="$2"

    local api_url="projects/$(url_encode "$project")/merge_requests/$(url_encode "$pr_num")"

    #echo "Calling API: $api_url" >&2
    local json="$(callGitlabAPI 'GET' "$api_url" '')"

    if [[ "$(jq -r .state <<<"$json")" = 'merged' ]]; then
        print_colored 'merged' 'bright_green'
    elif [[ "$(jq -r .work_in_progress <<<"$json")" = 'true' ]]; then
        print_colored 'work_in_progress' 'bright_yellow'
    elif [[ "$(jq -r .merge_status <<<"$json")" = 'cannot_be_merged' ]]; then
        print_colored 'cannot_be_merged' 'bright_red'
    else
        print_colored 'unmerged' 'bright_blue'
    fi
}

for inf in "${IN_FILES[@]}"; do
    if [[ $inf = '-' ]]; then
        inf=/dev/stdin
    fi

    # open the file handle
    if ! exec 5<"$inf"; then
        continue
    fi

    # read contents
    while read -u 5 pr_line; do
        # skip empty lines, and non-pr lines
        if [[ $pr_line =~ /merge_requests/ ]]; then
            pr_url="${pr_line#https://}"
            pr_url="${pr_url#*/}"
            proj_path="${pr_url%/merge_requests/*}"
            pr_num="${pr_url#*/*/*/}"
            state=$(report_pr_state "$proj_path" "$pr_num")
            echo "$pr_line: $state"
        else
            echo "$pr_line"
        fi
    done

    # close the file handle
    exec 5>&-
done
