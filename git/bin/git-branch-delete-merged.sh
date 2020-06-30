#!/bin/bash
# vi: sts=4 sw=4 ts=4 et

USAGE() {
    printf 'Usage: %s [OPTIONS] [--] BRANCH...\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Delete merged branches.

  -h        Show this help message.
  -f        Delete branch even if git doesn't want us to.
  -i        Show prompt before deleting branches (default).
  -X PAT    Exclude branches matching regex PAT.
  --        Terminate options list.

Copyright (C) 2020 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
}

INTERACTIVE=1
EXCLUDE=

while getopts 'fhiX:-' FLAG; do
    case "$FLAG" in
        'f')
            INTERACTIVE=0
            ;;
        'i')
            INTERACTIVE=1
            ;;
        'X')
            EXCLUDE=$OPTARG
            ;;
        'h')
            HELP_MESSAGE
            exit 0
            ;;
        *)
            printf 'Unrecognized flag: %s\n' \
                "$FLAG" \
                >&2
            USAGE >&2
            exit 1
            ;;
    esac
done

shift "$((OPTIND-1))"

ask_yn() (
    PROMPT=$1
    DEFAULT=$2
    read -r -p "$PROMPT [$([[ $DEFAULT = 'y' ]] && echo 'Y/n' || echo 'y/N')]? " ANSWER
    [[ $ANSWER =~ [YNyn10] ]] || ANSWER=$DEFAULT
    # return
    [[ $ANSWER =~ [Yy1] ]]
)

merged_local_branches() (
    # TODO replace with `git branch --show-current` when it's more
    # widely-supported
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    LC_MESSAGES=C \
    git branch \
        --color=never \
        --no-column \
        --merged "${1:-HEAD}" |
    while IFS= read -r LINE; do
        # cut '* branch' -> 'branch'
        LINE=${LINE:2}
        if [[ ! ( $LINE = "$CURRENT_BRANCH" || $LINE =~ ^\(HEAD\ detached ) ]]; then
            printf '%s\n' "$LINE"
        fi
    done
)

contains_this_branch() (
    LC_MESSAGES=C \
    git branch \
        --color=never \
        --no-column \
        --contains "$1" |
    while IFS= read -r LINE; do
        # cut '* branch' -> 'branch'
        LINE=${LINE:2}
        if [[ ! ( $LINE = "$1" || $LINE =~ ^\(HEAD\ detached ) ]]; then
            printf '%s\n' "$LINE"
        fi
    done
)

delete_branch() {
    git branch -D "$BRANCH"
}

for BRANCH in $(merged_local_branches "$@"); do
    if [[ -n $EXCLUDE && $BRANCH =~ $EXCLUDE ]]; then
        # skipped because excluded (-X)
        continue
    fi
    if [[ $INTERACTIVE -ne 0 ]]; then
        GO_AHEAD=0
        readarray -t CONTAINS < <(
            contains_this_branch "$BRANCH"
        )
        if ask_yn "Delete branch $BRANCH (contained in $(IFS=','; echo "${CONTAINS[*]}"))?" 'n'; then
            GO_AHEAD=1
        fi
    else
        GO_AHEAD=1
    fi
    if [[ $GO_AHEAD -ne 0 ]]; then
        delete_branch "$BRANCH" || exit
    fi
done
