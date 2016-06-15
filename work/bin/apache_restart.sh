#!/usr/bin/env bash

#FORCE=0
#
#while getopts 'f' flag; do
#	case "$flag" in
#		'f')
#			FORCE=1
#			;;
#		*)
#			echo "Unknown option $flag" >&2
#			exit 1
#			;;
#	esac
#done
#
#shift "$((OPTIND-1))"

case "$(uname -s)" in
	'FreeBSD')
		sudo service /usr/local/etc/rc.d/apache22 restart
		;;
	*)
		sudo service apache2 restart
		;;
esac
