#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# target: https://git.g2planet.com/<PROJECT>/-/commit/<COMMIT_SHA>/pipelines?ref=<BRANCH>

HELP_MESSAGE() {
    local EXIT_CODE="${1:-0}"
    cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--]
Open a web browser to Gitlab to a pipeline.

  -h        Show this help message.
  -s BRANCH Set source branch (defaults to current branch).
  --        Terminate options list.

Copyright (C) 2020 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
    exit "$EXIT_CODE"

}

SOURCE_BRANCH=
while getopts 'hs:' flag; do
    case "$flag" in
        's')
            SOURCE_BRANCH=$OPTARG
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
    SOURCE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z $SOURCE_BRANCH ]]; then
        printf 'Unable to determine current branch (are you in a git directory?)\n' >&2
        exit 2
    fi
fi

REMOTE=$(git config "branch.$SOURCE_BRANCH.remote")
if [[ -z $REMOTE ]]; then
    # I guess $SOURCE_BRANCH refers to a remote branch
    REMOTE=${SOURCE_BRANCH%%/*}
fi
if [[ -z $REMOTE ]]; then
    printf 'Unable to determine remote for branch "%s"\n' "$SOURCE_BRANCH" >&2
    exit 2
fi

# construct URL
COMMIT=$(git rev-parse "$SOURCE_BRANCH") || exit
ARGS="?ref=$SOURCE_BRANCH"
PUSH_URL=$(git remote -v |sed -e 's#^'"$REMOTE"'\s*\(.*\)\s*(push)$#\1# p;d')
HTTP_URL=$(echo $PUSH_URL |perl -p -e ' s#^ssh://##; s#:\d+/#/#; if (m#^\w*@#) { s#:#/#g; s#^\w*@#https://#; } s#\.git$##;')

if [[ ! $HTTP_URL =~ ^http ]]; then
    printf 'Unable to determine remote URL for remote branch "%s"\n' "$REMOTE" >&2
    exit 2
fi

PIPE_VIEW_URL="$HTTP_URL/-/commit/$COMMIT/pipelines$ARGS"

google-chrome "$PIPE_VIEW_URL"
