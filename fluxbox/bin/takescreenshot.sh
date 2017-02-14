#!/bin/bash

# uses imagemagick's import(1) utility to take a screenshot of the current
# window

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"

	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [FILE]...
Take a quick screenshot and save it to a file.

  -h            Show this help message.
  -d SECONDS    Wait this long before taking a screenshot.
  -a            Take a screenshot of the entire desktop.
  -w            Take a screenshot of a single window including frame (default).
  -v            Verbose output.
  -O            Optimize the output file using pngcrush(1) or optipng(1).

By default, the screenshot is output to ./screenshot-YYYY-MMDD-HHMM[-?].png,
otherwise it/they will be output to FILE.

Copyright (C) 2010-2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

ROOT_WINDOW=0
VERBOSE=0
DELAY=0
OPTIMIZE=0

while getopts 'd:awvOh' flag; do
	case "$flag" in
		'd')
			DELAY="$OPTARG"
			;;
		'a')
			ROOT_WINDOW=1
			;;
		'w')
			ROOT_WINDOW=0
			;;
		'v')
			VERBOSE=1
			;;
		'O')
			OPTIMIZE=1
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

choose_output() {
	local \
		image_suffix='.png' \
		image_base="screenshot-$(date '+%Y-%m%d-%H%M')" \
		image_out \
		dup_ct

	image_out="$image_base$image_suffix"

	# find a non-existant place to put the image
	while [[ -e "$image_out" ]]; do
		# this creates or increments the variable, starting with 1
		#dup_ct="$((${dup_ct:-0}+1))"
		let dup_ct+=1
		image_out="${image_base}-${dup_ct}$image_suffix"
	done

	echo "$image_out"
}

optimize_image() {
	local \
		image \
		mimetype \
		origsize \
		newsize \
		temp_out

	for image; do

		temp_out="$(mktemp -t "$(basename -- "$0").XXXXXX")"

		mimetype="$(file --brief --mime-type -- "$image")"
		origsize="$(($(stat -c %s -- "$image" 2>/dev/null)+0))"

		case "$mimetype" in
			'image/png')
				if [[ -n "$(type -Pt 'optipng')" ]]; then
					# optipng refuses to overwrite files
					rm -f -- "$temp_out"
					optipng \
						-fix \
						-force \
						-preserve \
						-out "$temp_out" \
						-- \
						"$image"
				elif [[ -n "$(type -Pt 'pngcrush')" ]]; then
					# note: pngcrush can't handle input
					# files starting with `-'
					pngcrush \
						-q \
						-brute "$image" \
						"$temp_out"
				fi
				;;
			'image/jpeg')
				# note: jpegtran and jhead can't handle input
				# files starting with `-'
				jpegtran \
					-optimize \
					-outfile "$temp_out" \
					"$image" &&

				# copy EXIF information from original
				# file to the temporary file
				jhead \
					-te "$temp_out" \
					"$image"
				;;
			*)
				echo "image type of \`$image_file' not recognized" >&2
				;;
		esac
		newsize="$(($(stat -c %s -- "$temp_out" 2>/dev/null)+0))"
		if [[ "$newsize" -gt 0 && "$newsize" -lt "$origsize" ]]; then
			touch --reference="$image" -- "$temp_out"
			chmod --reference="$image" -- "$temp_out"
			if [[ "$UID" -eq 0 ]]; then
				# we're root
				chown --reference="$image" -- "$temp_out"
			fi

			# copy the image over the new one
			cp -p -- "$temp_out" "$image"
		fi

		rm -f -- "$temp_out"
	done
}

OUTPUTS=("$@")

if [[ "${#OUTPUTS[@]}" -eq 0 ]]; then
	OUTPUTS+=("$(choose_output)")
fi

import_opts=(
	'-quality' '9'	# JPEG/MIFF/PNG compression level
)

if [[ "$ROOT_WINDOW" -ne 0 ]]; then
	import_opts+=(
		'-screen' # select image from root window
	)
fi

if [[ "$VERBOSE" -ne 0 ]]; then
	import_opts+=(
		'-verbose' # print detailed information about the image
		'-monitor' # monitor progress
	)
fi

for image_out in "${OUTPUTS[@]}"; do
	sleep "$DELAY"
	import "${import_opts[@]}" "$image_out"
done

# finisher: optimize images for size
if [[ "$OPTIMIZE" -ne 0 ]]; then
	for image_out in "${OUTPUTS[@]}"; do
		if [[ -f "$image_out" ]]; then
			optimize_image "$image_out"
		fi
	done
fi

# vi: ts=4 sts=4 sw=4 noet
