#!/bin/sh

current_volume="$(
	amixer cget iface=MIXER,name='Master Playback Volume' |
	grep -Po ': values=\d+' |
	cut -f 2- -d '='
)"

echo "current: $current_volume"

# absolute value integer adjustment
adjustby="${1:1}"

# +5 or -5
case "${1:0:1}" in
	'-')
		newvol="$((current_volume-adjustby/5))"
		break
		;;
	'+')
		newvol="$((current_volume+adjustby/5))"
		break
		;;
	*)
		# set absolute volume
		newvol="$adjustby"
		break
		;;
esac

exec amixer cset iface=MIXER,name='Master Playback Volume' "$newvol"
