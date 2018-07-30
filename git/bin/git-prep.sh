#!/bin/bash

git_basedir=$(git rev-parse --show-toplevel)
if [[ -z $git_basedir ]]; then
    echo 'Failed to find git root directory' 1>&2
    exit 2
fi

# cheat the "alternates" file
if [[ -f "$git_basedir/.gitmodules" ]]; then
    submodules=(
        $(git config -f "$git_basedir/.gitmodules" --get-regexp --name-only '^submodule\..*\.url$' | cut -f 2 -d .)
    )
    for sm in "${submodules[@]}"; do
        localcopy=~/.gitrepos/$(basename -- "$sm").git
        if [[ -d $localcopy/objects ]]; then
            git submodule update --init --reference "$localcopy" "$sm" || exit
        fi
    done
fi

git submodule update --recursive --init || exit
git-alts.sh
git gc

git remote rename origin o
git submodule foreach --recursive 'git remote rename origin o;true'

if [[ -f composer.json || -f composer.lock ]]; then
    composer install --quiet || exit
fi
