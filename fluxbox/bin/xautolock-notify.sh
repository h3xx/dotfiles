#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# Name:
#   xautolock-notify.sh - Send a desktop notification from xautolock
#
# Synopsis:
#   xautolock-notify.sh [SECONDS]
#
# Copyright (C) 2010-2015 Dan Church.
# License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.


ICON='/usr/share/icons/Tango/scalable/actions/system-lock-screen.svg'
APP='xautolock'
DEFAULT_DURATION=15000 # ms

from_now() (
    DIFF=$1
    PRECISION=${2:-3}

    rpt() {
        printf '%d %s%s ' "$1" "$2" \
            "$([[ $1 -gt 1 ]] && echo 's')"
    }
    if [[ $DIFF -lt 0 ]]; then
        DESC='ago'
    else
        DESC='from now'
    fi
    _DAYS=$(( DIFF / 3600 / 24 ))
    _HOURS=$((DIFF % (3600 * 24) / 3600))
    _MINUTES=$(( DIFF % 3600 / 60 ))
    _SECONDS=$(( DIFF % 60 ))
    if [[ $PRECISION -gt 0 && $_DAYS -gt 0 ]]; then
        rpt "$_DAYS" 'day'
        (( --PRECISION ))
    fi
    if [[ $PRECISION -gt 0 && $_HOURS -gt 0 ]]; then
        rpt "$_HOURS" 'hour'
        (( --PRECISION ))
    fi
    if [[ $PRECISION -gt 0 && $_MINUTES -gt 0 ]]; then
        rpt "$_MINUTES" 'minute'
        (( --PRECISION ))
    fi
    if [[ $PRECISION -gt 0 && $_SECONDS -gt 0 ]]; then
        rpt "$_SECONDS" 'second'
        (( --PRECISION ))
    fi
    printf '%s' "$DESC"
)

if [[ -n $1 ]]; then
    MSG="The system will automatically lock $(from_now "$1")"
    # Stay showing until locked
    DURATION=$(( $1 * 1000 ))
else
    MSG="The system will automatically lock soon"
    DURATION=$DEFAULT_DURATION
fi

notify-send \
    --app-name="$APP" \
    --urgency=critical \
    --hint=int:transient:1 \
    --icon="$ICON" \
    --expire-time="$DURATION" \
    "$MSG"
