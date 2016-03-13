#!/bin/sh

# Version 1.1

SYSCONFDIRS=(
	/etc
	# system-wide vimrc has been known to stage changes with a .new file
	/usr/share/vim
)

APPLY_ALL=0
USE_COLORDIFF=1

while getopts 'aC' flag; do
	case "$flag" in
		'a')
			APPLY_ALL=1
			;;
		'C')
			USE_COLORDIFF=0
			;;
	esac
done

shift "$((OPTIND-1))"

# check to see if colordiff(1) is installed
if [ "$USE_COLORDIFF" -ne 0 ] && ! which colordiff >/dev/null 2>&1 ; then
	USE_COLORDIFF=0
fi

DIFF_OPTS=(
	'--side-by-side'
	'--report-identical-files'
	'--suppress-common-lines'
#	'--context=3'
)

DIFFTOOL=vimdiff

report_change() {
	local \
		old_conf="$1" \
		new_conf="$2"

	if [ -z "$new_conf" ]; then
		new_conf="${old_conf}.new"
	fi

	if [ -f "$old_conf" -a -f "$new_conf" ]; then

		echo '*****'
		if [ "$USE_COLORDIFF" -ne 0 ]; then
			diff "${DIFF_OPTS[@]}" -- "$old_conf" "$new_conf" |colordiff
		else
			diff "${DIFF_OPTS[@]}" -- "$old_conf" "$new_conf"
		fi
		echo '*****'
	else
		echo "error finding changes for configuration file '$old_conf' => '$new_conf'" >&2
	fi
}

accept_change() {
	local \
		old_conf="$1" \
		new_conf="$2"

	if [ -z "$new_conf" ]; then
		new_conf="${old_conf}.new"
	fi

	if [ -f "$old_conf" -a -f "$new_conf" ]; then
		mv -v -- "$new_conf" "$old_conf" || exit 1
	else
		echo "error applying changes for configuration file '$old_conf' => '$new_conf'" >&2
	fi
}

reject_change() {
	local \
		old_conf="$1" \
		new_conf="$2"

	if [ -z "$new_conf" ]; then
		new_conf="${old_conf}.new"
	fi

	if [ -f "$new_conf" ]; then
		rm -fv -- "$new_conf" || exit 1
	else
		echo "couldn't delete file '$new_conf'" >&2
	fi
}

edit_change() {
	local \
		old_conf="$1" \
		new_conf="$2"

	if [ -z "$new_conf" ]; then
		new_conf="${old_conf}.new"
	fi

	$DIFFTOOL "$old_conf" "$new_conf"
}

prompt_change() {
	local \
		old_conf="$1" \
		new_conf="$2" \
		answer

	if [ -z "$new_conf" ]; then
		new_conf="${old_conf}.new"
	fi

	if [ -f "$old_conf" -a -f "$new_conf" ]; then
		# show the user what they're accepting
		report_change "$old_conf" "$new_conf"

		if [ "$APPLY_ALL" -ne 0 ]; then
			# user wants to install all of them
			accept_change "$old_conf" "$new_conf"
		else
			read -p "$old_conf => $new_conf [y/N/e/d/a]? " answer
			case "${answer//[A-Z]/[a-z]}" in
				'a')
					INSTALL_ALL=1
					accept_change "$old_conf" "$new_conf"
					;;
				'y')
					accept_change "$old_conf" "$new_conf"
					;;
				'd')
					reject_change "$old_conf" "$new_conf"
					;;
				'e')
					edit_change "$old_conf" "$new_conf"
					prompt_change "$old_conf" "$new_conf"
					;;

				#*)
					# do nothing...
			esac
		fi
	fi
}


if [ "$#" -eq 1 ]; then
	# we're being called from find(1) or on a single file

	for nconf; do
		prompt_change "$(dirname -- "$nconf")/$(basename -- "$nconf" .new)" "$nconf"
	done
else
	# we're scheduling

	# send myself a message
	pass_opts=()
	if [ "$APPLY_ALL" -ne 0 ]; then
		pass_opts+=('-a')
	fi
	if [ "$USE_COLORDIFF" -eq 0 ]; then
		pass_opts+=('-C')
	fi

	find "${SYSCONFDIRS[@]}" \
		-type f \
		-name '*.new' \
		-exec "$0" "${pass_opts[@]}" {} \;
fi
