#!/bin/bash
# vi: et sts=4 sw=4 ts=4

. "$0.conf"

if [[ -z $GITLAB_API_URL || -z $GITLAB_TOKEN ]]; then
    printf 'Must specify GITLAB_TOKEN and GITLAB_API_URL in %s\n' "$0.conf" >&2
    exit 2
fi

HELP_MESSAGE() {
    local EXIT_CODE="${1:-0}"
    cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--] [BRANCH]...
List data about the GitLab merge requests associated with the branch.

  -h        Show this help message.
  -v        Verbose output
  --        Terminate options list.

Copyright (C) 2018 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"

}

VERBOSE=0
while getopts 'h:v' flag; do
    case "$flag" in
        'v')
            VERBOSE=1
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
        filter='.'
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

get_remote_url() {
    git config "remote.$1.url"
}

get_mr_info() {
    local \
        project="$1" \
        branch="$2"
        local api_url="projects/$(url_encode "$project")/merge_requests?source_branch=$(url_encode "$branch")"

    callGitlabAPI GET "$api_url" '' 'map({target_branch,web_url})'
}

REMOTE=$(git remote |head -1)
remote_url="$(get_remote_url "$REMOTE"|tr : /)"
PROJ="$(basename -- "$(dirname -- "$remote_url")")/$(basename -- "$remote_url" .git)"

BRANCHES=()
if [[ $# < 1 ]]; then
    # use current branch
    SOURCE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    if [[ -z $SOURCE_BRANCH ]]; then
        echo "Unable to determine current branch (are you in a git directory?)"
        exit 2
    fi
    BRANCHES=("$SOURCE_BRANCH")
else
    BRANCHES=("$@")
fi

for SOURCE_BRANCH in "${BRANCHES[@]}"; do
    if [[ $VERBOSE > 0 ]]; then
        printf 'Querying branch "%s"\n' "$SOURCE_BRANCH"
    fi
    get_mr_info "$PROJ" "$SOURCE_BRANCH"
done
