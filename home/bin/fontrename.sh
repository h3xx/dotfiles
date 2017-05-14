#!/bin/sh

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--] FILE...
Auto-rename font files according to the font's canonical name.

  -h		Show this help message.

Copyright (C) 2011-2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

while getopts 'h' flag; do
	case "$flag" in
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
	rm -rf -- "${TEMP_FILES[@]}"
}

trap 'cleanup'	EXIT

# prints out the simple mimetype (e.g. `image/jpeg') of a file's contents
get_mimetype() {
	file \
		--preserve-date \
		--dereference \
		--brief \
		--mime-type \
		-- \
		"$@" 2>/dev/null
}

fontname() {
	local \
		font="$1" \
		mimetype \
		tempdir \
		result=1

	mimetype="$(get_mimetype "$font")"
	case "$mimetype" in

		'application/x-font-ttf')
			# XXX : for some reason, ttf2afm requires a .ttf file
			#	extension, so the creation of a temporary
			#	symlink is necessary

			tempdir="$(mktemp -d -t "$(basename -- "$0").XXXXXX")"
			TEMP_FILES+=("$tempdir")

			ln -sf -- "$(readlink -m -- "$font")" "$tempdir/foo.ttf" &&

			# XXX : segfaulting ttf2afm needs this to die safely
			(trap 'true' ERR; exec ttf2afm -- "$tempdir/foo.ttf") |
			grep -- '^FullName ' |
			cut --fields='2-' --delimiter=' ' |
			head --lines='1'

			result="$?"

			# XXX : code for when/if ttf2afm is ever fixed so that
			#	it doesn't require a .ttf file extension

			#ttf2afm -- "$font" |
			#grep -- '^FullName ' |
			#cut --fields='2-' --delimiter=' ' |
			#head --lines='1'
			#
			#result="$?"

			;;

		# FIXME : file(1) may be reporting the wrong mimetype the long
		#	  filetype is "ASCII font metrics"
		'text/x-fortran'|'text/plain'*)
			grep -- '^FullName ' "$font" |
			cut --fields='2-' --delimiter=' ' |
			head --lines='1'

			result="$?"
			;;

		*)
			echo "Unsupported font mimetype: \`$mimetype'" >&2
			;;
	esac

	return "$result"
}

# prints the file extension--including the period--for a given font file, based
# on that file's detected mimetype (via file(1))
#
# supports:
#	application/x-font-ttf		(truetype => `.ttf')
#	application/x-font-type1	(adobe => `.afm') -- often mis-typed as text/x-fotran
#	application/vnd.ms-opentype	(opentype => `.otf')
#	application/x-font-woff		(woff => `.woff')
#	application/vnd.ms-fontobject	(m$ eot file => `.eot')
#
# arguments:
#	$1: the font file
fontext() {
	local \
		font="$1" \
		mimetype \
		result=1

	mimetype="$(get_mimetype "$font")"
	case "$mimetype" in

		'application/x-font-ttf')
			echo '.ttf'
			;;

		# FIXME : file(1) is probably reporting the wrong mimetype
		#	  the long filetype is "ASCII font metrics"
		'application/x-font-type1'|'text/x-fortran'|'text/plain'*)
			echo '.afm'
			result=0
			;;

		'application/vnd.ms-opentype')
			echo '.otf'
			result=0
			;;

		'application/x-font-woff')
			echo '.woff'
			result=0
			;;

		'application/vnd.ms-fontobject')
			echo '.eot'
			result=0
			;;

		*)
			echo "Unsupported font mimetype: \`$mimetype'" >&2
			;;
	esac

	return "$result"
}

rename_font() {
	local \
		font \
		ext \
		fontbase \
		fontdir \
		name \
		target

	for font; do
		name="$(fontname "$font")"
		ext="$(fontext "$font")"
		fontbase="$(basename -- "$font")"
		fontdir="$(dirname -- "$font")"
		target="${fontdir}/${name}${ext}"
		if [ -z "$name" ]; then
			echo "Cannot rename font \`$font': no full name found" >&2
		elif [ -z "$ext" ]; then
			echo "Cannot rename font \`$font': no extension" >&2
		elif [ "z$fontbase" == "z${name}${ext}" ]; then
			echo "Font \`$font' already renamed" >&2
		elif [ -e "$target" ]; then
			echo "Cannot rename font \`$font': \`$target' already exists" >&2
		else
			mv -v -- "$font" "$target"
		fi
	done
}

rename_font "$@"
