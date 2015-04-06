#!/bin/sh

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [XPM_FILE]...
Resize XPM icons to a given size.

  -h		Show this help message.
  -f		Force over-writing output files.
  -o DIR	Write new icons to [DIR]/[BASENAME].xpm. Default is \`.'.
  -s DIMS	New dimenstions in the format \`[PIXELS_X]x[PIXELS_Y]' or
		  \`[PIXELS_X_AND_Y]' (for square images). Default is 12.

Copyright (C) 2010 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

DIMS='12x12'
OUT_DIR='.'
FORCE=0

while getopts 'hs:o:f' flag; do
	case "$flag" in
		's')
			DIMS="$OPTARG"
			;;
		'o')
			OUT_DIR="$OPTARG"
			;;
		'f')
			FORCE=1
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

TEMP_FILES=()

cleanup() {
	rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup'	EXIT

# determine x and y sizes
if [[ $DIMS == *[^0-9]* ]]; then
	# split dimension
	xsize="$(echo "$DIMS" |tr -c '[:digit:]' '\n' |head -1)"
	ysize="$(echo "$DIMS" |tr -c '[:digit:]' '\n' |tail -1)"
else
	# use as square dimension
	xsize="$DIMS"
	ysize="$DIMS"
fi

if [ -z "$ysize" -o -z "$xsize" ]; then
	echo "error: invalid dimensions: \`$DIMS' (must contain a number)" >&2
	exit 1
fi

resize_xpm() {
	local \
		in="$1" \
		out="$2" \
		xsize="$3" \
		ysize="$4" \
		alpha_temp \
		image_temp_r \
		alpha_temp_r \
		xpm_name

	alpha_temp="$(mktemp -t "$(basename -- "$0").XXXXXX")"
	image_temp_r="$(mktemp -t "$(basename -- "$0").XXXXXX")"
	alpha_temp_r="$(mktemp -t "$(basename -- "$0").XXXXXX")"

	TEMP_FILES+=(
		"$alpha_temp"
		"$image_temp_r"
		"$alpha_temp_r"
	)

	# determine the xpm's internal name
	xpm_name="$(basename -- "$out" |tr . _)"

	# extract the alpha channel, scale the rest and save it
	xpmtoppm "$in" --alphaout="$alpha_temp" |
	pnmscale \
		-xsize="$xsize" \
		-ysize="$ysize" >"$image_temp_r" &&

	# scale the alpha channel and save it
	pnmscale \
		-xsize="$xsize" \
		-ysize="$ysize" \
		"$alpha_temp" >"$alpha_temp_r" &&

	# glue the resized parts back together into an xpm
	ppmtoxpm \
		-name="$xpm_name" \
		-alphamask="$alpha_temp_r" \
		"$image_temp_r" >"$out"
}

[ "$#" -ne 0 ] || HELP_MESSAGE 2

# start resizing images
for xpm; do
	outname="$OUT_DIR/$(basename -- "$xpm")"
	if [ "$FORCE" -eq 0 -a -e "$outname" ]; then
		echo "output file \`$outname' already exists (force overwrite with -f)" >&2
	else
		resize_xpm \
			"$xpm" \
			"$outname" \
			"$xsize" \
			"$ysize"
	fi
done
