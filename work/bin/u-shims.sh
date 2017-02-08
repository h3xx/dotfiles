#!/bin/bash

EVENTLIB=git@git.g2planet.com:g2planet/eventlib.git

# prevent re-download of all objects
export GIT_ALTERNATE_OBJECT_DIRECTORIES=$HOME/.gitrepos/eventlib.git/objects

TEMP_FILES=()
cleanup() {
	rm -rf -- "${TEMP_FILES[@]}"
}
trap 'cleanup'	EXIT

workdir="$(mktemp -d -t "$(basename -- "$0").XXXXXX")"
TEMP_FILES+=("$workdir")

git clone "$EVENTLIB" "$workdir" || exit

for fn in *.php; do
    find "$workdir" \
        ! \( -regextype posix-egrep -regex '.*/(\.(svn|git|hg|bzr)|CVS)(/.*)?' \) \
        -name "$fn" \
        -exec cp -vp -- {} . \;
done
