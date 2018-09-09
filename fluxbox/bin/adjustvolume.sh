#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# USB sound card
MIXER_NAME='PCM Playback Volume'
# internal sound card
#MIXER_NAME='Master Playback Volume'

CURRENT_VOLUME=$(
    amixer cget iface=MIXER,name="$MIXER_NAME" |
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
        ;;
    '+')
        NEWVOL=$((CURRENT_VOLUME+ADJUSTBY/5))
        ;;
    *)
        # set absolute volume
        NEWVOL=$ADJUSTBY
        ;;
esac

exec amixer cset iface=MIXER,name="$MIXER_NAME" "$NEWVOL"
