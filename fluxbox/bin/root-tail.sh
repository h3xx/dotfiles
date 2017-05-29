#!/bin/bash
# vi: et sts=4 sw=4 ts=4

CONF=$0.conf

RT_PID=$(/sbin/pidof 'root-tail' 2>/dev/null)
if [[ -n $RT_PID ]]; then
    printf 'root-tail is already running on pid %d\n' "$RT_PID" >&2
    exit 2
fi

set -e

if [[ ! -f $CONF ]]; then
    printf 'Failed to find config file "%s"\n' "$CONF" >&2
    exit 2
fi

# Default config
LOGS=()

. "$CONF"

ROOT_TAIL_ARGS=("${EXTRA_ARGS[@]}")

for (( i = 0; i < ${#LOGS[@]}; i += 3 )); do
    FILE=${LOGS[i]}
    COLOR=${LOGS[i+1]}
    LABEL=${LOGS[i+2]}

    if [[ -r $FILE && -f $FILE ]]; then
        # can tail it
        ROOT_TAIL_ARGS+=(
            "${FILE}${COLOR:+,${COLOR}}${LABEL:+,${LABEL}}"
        )
    else
        printf 'Warning: Cannot read log file "%s"\n' "$FILE" >&2
    fi
done

exec root-tail "${ROOT_TAIL_ARGS[@]}"
