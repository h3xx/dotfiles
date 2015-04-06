#!/bin/sh

TEMP_FILES=()

function cleanup {
	rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup'	EXIT

alpha_temp="$(mktemp -t "$(basename "$0").XXXXXX")"
TEMPFILES+=("$alpha_temp")

for png; do
	xpm="$(basename -- "$png" .png).xpm"
	name="$(basename -- "$xpm" |tr . _)"

	rm -fv -- "$xpm"

	# extract the alpha channel
	pngtopnm -alpha "$png" >"$alpha_temp" &&

	# reconstruct the XPM using the saved alpha channel
	pngtopnm "$png" |
	ppmtoxpm -alphamask="$alpha_temp" -name="$name" >"$xpm"
done
