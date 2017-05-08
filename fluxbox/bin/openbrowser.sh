#!/bin/bash
# vi: et sts=4 sw=4 ts=4

SQUID=1

CHROME_OPTIONS=(
    --ignore-gpu-blocklist
    --purge-memory-button
    --process-per-site
    --wm-window-animations-disabled
)

if [[ $SQUID -ne 0 ]]; then
    CHROME_OPTIONS+=(
        --proxy-server='http://localhost:3128'
        --proxy-bypass-list='localhost'
    )
fi

exec google-chrome \
    "${CHROME_OPTIONS[@]}" \
    "$@"
