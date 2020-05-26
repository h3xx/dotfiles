#!/bin/bash
# vi: et sts=4 sw=4 ts=4

upstream_ref() {
    # TODO replace with `git branch --show-current` when it's more
    # widely-supported
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z $CURRENT_BRANCH ]]; then
        printf 'fatal: could not determine upstream of HEAD when it does not point to any branch.\n' \
            >&2
        exit 128
    fi

    REMOTE=$(git config "branch.$CURRENT_BRANCH.remote")
    REF=$(git config "branch.$CURRENT_BRANCH.merge")
    if [[ -z $REMOTE || -z $REF ]]; then
        printf 'fatal: could not determine upstream of %s when it does not have an upstream set.\n' \
            "$CURRENT_BRANCH" \
            >&2
        exit 128
    fi

    # With...
    # - REF=refs/heads/master
    # - REMOTE=origin
    # ...eliminate 'refs/heads' to make it 'refs/remotes/origin/master'
    printf 'refs/remotes/%s/%s' "$REMOTE" "${REF:11}"
}

# Act as a stand-in for "git reset," which doesn't support `-` or `--upstream`
# and gives a confusing and unhelpful error message: "fatal: option '-' must
# come before non-option arguments"
GIT_ARGS=()

for ARG; do
    case "$ARG" in
        -)
            GIT_ARGS+=('@{-1}')
            ;;
        --upstream)
            GIT_ARGS+=("$(upstream_ref)")
            ;;
        *)
            GIT_ARGS+=("$ARG")
            ;;
    esac
done
exec git reset "${GIT_ARGS[@]}"
