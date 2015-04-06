#!/bin/sh

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") PNG [NAME]
Add an icon for the Fluxbox menu, automatically resizing.

PNG is the input icon file.
NAME is the name of the .xpm file for output.

Copyright (C) 2012-2013 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

TEMP_FILES=()

cleanup() {
	rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup'	EXIT

ICON_X="${ICON_X:-12}"
ICON_Y="${ICON_Y:-$ICON_X}"
ICON_FS_DIR="$HOME/.fluxbox/icons-fullsize"
ICON_DIR="${ICON_DIR:-$HOME/.fluxbox/icons-${ICON_X}x${ICON_Y}}"

file_size() {
	# adds all the file sizes by doing a stat on all of them (separated by
	# `\n'), transforming them into `LINE+LINE+...LINE+0' and passing them
	# to the Bash expression evaluator
	echo "$(($(
		stat \
			--format='%s' \
			--dereference \
			-- \
			"$@" 2>/dev/null |
		tr '\n' '+'
	)0))"
}

img_to_pnm() {
	local \
		in="$1" \
		out="$2" \
		out_alpha="$3" \
		in_mime

	in_mime="$(file --mime-type --brief -- "$in")"
	in_mime_long="$(file --brief -- "$in")"

	case "$in_mime" in

		'image/png')
			pngtopnm -alpha "$in" >"$out_alpha" &&
			pngtopnm "$in" >"$out" ||
			return
			;;
			
		'image/gif')
			giftopnm --alphaout="$out_alpha" "$in" >"$out" ||
			return
			;;

		'text/x-c')
			[ "$in_mime_long" == 'X pixmap image text' ] &&
			xpmtoppm --alphaout="$out_alpha" "$in" >"$out" ||
			return
			;;

		*)
			echo "Image type \`$in_mime' not supported." >&2
			return 1
			;;
	esac
}

pnm_to_xpm() {
	local \
		in="$1" \
		in_alpha="$2" \
		out="$3" \
		xpm_name="$4"

	if [ -z "$xpm_name" ]; then
		xpm_name="$(basename -- "$out" |tr '.-' '__')"
	fi

	if [ -f "$in_alpha" -a "$(file_size "$in_alpha")" -gt 0 ]; then
		# has an alpha layer
		ppmtoxpm \
			-alphamask="$in_alpha" \
			-name="$xpm_name" \
			"$in" >"$out" ||
		return
	else
		ppmtoxpm \
			-name="$xpm_name" \
			"$in" >"$out" ||
		return
	fi
}

resize_pnm() {
	local \
		in="$1" \
		in_alpha="$2" \
		out="$3" \
		out_alpha="$4" \
		xsize="$5" \
		ysize="$6"

	pnmscale \
		-xsize="$xsize" \
		-ysize="$ysize" \
		"$in" >"$out" ||
	return

	if [ -f "$in_alpha" -a "$(file_size "$in_alpha")" -gt 0 ]; then
		# has an alpha layer
		pnmscale \
			-xsize="$xsize" \
			-ysize="$ysize" \
			"$in_alpha" >"$out_alpha" ||
		return
	fi

}

convert_img_xpm() {
	local \
		in="$1" \
		out="$2" \
		xsize="${3:-0}" \
		ysize="${4:-0}" \
		alpha_temp \
		image_temp \
		image_temp_r \
		alpha_temp_r \
		xpm_name

	xpm_name="$(basename -- "$out" |tr '.-' '__')"

	alpha_temp="$(mktemp -t "$(basename -- "$0").XXXXXX")"
	image_temp="$(mktemp -t "$(basename -- "$0").XXXXXX")"
	image_temp_r="$(mktemp -t "$(basename -- "$0").XXXXXX")"
	alpha_temp_r="$(mktemp -t "$(basename -- "$0").XXXXXX")"

	TEMP_FILES+=(
		"$alpha_temp"
		"$image_temp"
		"$image_temp_r"
		"$alpha_temp_r"
	)

	img_to_pnm \
		"$in" \
		"$image_temp" "$alpha_temp" ||
	return

	if [ "$xsize" -gt 0 -a "$ysize" -gt 0 ]; then
		resize_pnm \
			"$image_temp" "$alpha_temp" \
			"$image_temp_r" "$alpha_temp_r" \
			"$xsize" "$ysize" ||
		return
	else
		cat -- "$image_temp" >"$image_temp_r" &&
		cat -- "$alpha_temp" >"$alpha_temp_r" ||
		return
	fi

	pnm_to_xpm \
		"$image_temp_r" "$alpha_temp_r" \
		"$out" \
		"$xpm_name" ||
	return
}

add_icon() {
	local \
		from_img="$1" \
		name="$2" \
		in_mime \
		fullsize \
		small

	if [ -z "$name" ]; then
		name="$(basename -- "${from_img%.*}")"
		echo "Using name \`$name'" >&2
	fi

	fullsize="$ICON_FS_DIR/${name}.xpm"
	small="$ICON_DIR/${name}.xpm"

	# (not specifying the xsize and ysize will yield an unscaled XPM)
	echo "Writing full size image to \`$fullsize'" >&2
	convert_img_xpm \
		"$from_img" "$fullsize" &&

	echo "Writing ${ICON_X}x${ICON_Y} image to \`$small'" >&2 &&
	convert_img_xpm \
		"$from_img" "$small" \
		"$ICON_X" "$ICON_Y"
}

if [ "$#" -lt 1 ]; then
	HELP_MESSAGE 1
fi

add_icon "$@"
