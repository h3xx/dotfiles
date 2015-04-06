#!/bin/bash
# vi: et sts=4 sw=4 ts=4

CURRENT_VOLUME=$(
    amixer cget iface=MIXER,name='Master Playback Volume' |
    grep -Po ': values=\d+' |
    cut -f 2- -d '='
)

echo "current: $CURRENT_VOLUME"

# absolute value integer adjustment
ADJUSTBY=${1:1}

# +5 or -5
case "${1:0:1}" in
    '-')
        NEWVOL=$((CURRENT_VOLUME-ADJUSTBY/5))
        break
        ;;
    '+')
        NEWVOL=$((CURRENT_VOLUME+ADJUSTBY/5))
        break
        ;;
    *)
        # set absolute volume
        NEWVOL=$ADJUSTBY
        break
        ;;
esac

exec amixer cset iface=MIXER,name='Master Playback Volume' "$NEWVOL"
