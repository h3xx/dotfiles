#!/bin/bash
# vi: et sts=4 sw=4 ts=4

CHROME_OPTIONS=(
    --ignore-gpu-blocklist
    --purge-memory-button
    --process-per-site
    --wm-window-animations-disabled
)

exec google-chrome \
    "${CHROME_OPTIONS[@]}" \
    "$@"
