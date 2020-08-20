#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# TODO don't switch branches' remotes if they already have one

WHOAMI=git-tattle

USAGE() {
    printf 'Usage: %s [OPTIONS] BRANCH... [--]\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Tell remote about current branch.

  -h        Show this help message.
  -r REMOTE Set remote to REMOTE (defaults to first remote).
  -i        Interactively select a remote.
  --        Terminate options list.

Copyright (C) 2016-2020 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
}

INTERACTIVE=0
REMOTE=

while getopts 'hir:' FLAG; do
    case "$FLAG" in
        'r')
            REMOTE=$OPTARG
            ;;
        'i')
            INTERACTIVE=1
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

ask_list() (
    PROMPT=$1
    DEFAULT=$2
    shift 2
    OPTIONS=("$@")
    for ((i = 0; i < ${#OPTIONS[@]}; ++i)); do
        printf '%d. %s' "$i" "${OPTIONS[$i]}" >&2
        if [[ $i -eq $DEFAULT ]]; then
            printf ' (default)' >&2
        fi
        printf '\n' >&2
    done
    ANS=
    FULL_PROMPT="$PROMPT [$DEFAULT]? "
    read -r -p "$FULL_PROMPT" ANS
    while [[ ! $ANS =~ ^[0-9]*$ || $ANS -lt 0 || $ANS -ge ${#OPTIONS[@]} ]]; do
        printf 'Invalid input: %s\n' "$ANS" >&2
        read -r -p "$FULL_PROMPT" ANS
    done
    if [[ -z $ANS ]]; then
        ANS=$DEFAULT
    fi
    echo "${OPTIONS[$ANS]}"
)

if [[ -z $REMOTE ]]; then
    readarray -t REMOTES < <(
        git remote
    )
    if [[ ${#REMOTES[@]} -gt 1 ]]; then
        if [[ $INTERACTIVE -ne 0 ]]; then
            REMOTE=$(ask_list 'Which remote' 0 "${REMOTES[@]}")
        else
            REMOTE=${REMOTES[0]}
            printf '%s: Auto-selecting remote %s from %d remotes\n' "$WHOAMI" "$REMOTE" "${#REMOTES[@]}" >&2
        fi
    elif [[ ${#REMOTES[@]} -gt 0 ]]; then
        REMOTE=${REMOTES[0]}
        printf '%s: Auto-using remote %s\n' "$WHOAMI" "$REMOTE" >&2
    fi
fi

if [[ -z $REMOTE ]]; then
    printf '%s: Unable to determine remote\n' "$WHOAMI" >&2
    exit 2
fi

if [[ $# -ne 0 ]]; then
    for BRANCH; do
        git push --set-upstream "$REMOTE" "$BRANCH"
    done
else
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z $BRANCH ]]; then
        printf '%s: Unable to determine current branch (are you in a git directory?)\n' "$WHOAMI" >&2
        exit 2
    fi
    git push --set-upstream "$REMOTE" "$BRANCH"
fi
