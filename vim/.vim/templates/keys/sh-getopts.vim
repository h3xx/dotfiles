" getopts structure for shell scripts

append
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
.
