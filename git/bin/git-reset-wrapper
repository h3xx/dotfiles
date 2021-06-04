#!/bin/bash
# vi: et sts=4 sw=4 ts=4

upstream_ref() {
    BRANCH=$(git branch --show-current)
    if [[ -z $BRANCH ]]; then
        echo 'fatal: could not determine upstream of HEAD when it does not point to any branch.' >&2
        exit 128
    fi

    REMOTE=$(git config "branch.$BRANCH.remote")
    REF=$(git config "branch.$BRANCH.merge")
    if [[ -z $REMOTE || -z $REF ]]; then
        echo "fatal: could not determine upstream of $BRANCH when it does not have an upstream set." >&2
        exit 128
    fi

    # With...
    # - REF=refs/heads/master
    # - REMOTE=origin
    # ...eliminate 'refs/heads' to make it 'refs/remotes/origin/master'
    printf 'refs/remotes/%s/%s' "$REMOTE" "${REF:11}"
}

# Act as a stand-in for the "git reset" alias, which doesn't support `-` and
# gives a confusing and unhelpful error message: "fatal: option '-' must come
# before non-option arguments"
GIT_ARGS=()

for arg; do
    if [[ $arg = - ]]; then
        arg='@{-1}'
    elif [[ $arg = --upstream ]]; then
        arg=$(upstream_ref)
    fi
    GIT_ARGS+=("$arg")
done
exec git reset "${GIT_ARGS[@]}"
