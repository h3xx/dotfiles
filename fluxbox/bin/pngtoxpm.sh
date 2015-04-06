#!/bin/bash
# vi: et sts=4 sw=4 ts=4

TEMP_FILES=()

cleanup() {
    rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup' EXIT

ALPHA_TEMP=$(mktemp -t "${0##*/}.XXXXXX")
TEMPFILES+=("$ALPHA_TEMP")

for PNG; do
    XPM=$(basename -- "$PNG" .png).xpm
    NAME=$(basename -- "$XPM" |tr . _)

    rm -fv -- "$XPM"

    # extract the alpha channel
    pngtopnm -alpha "$PNG" >"$ALPHA_TEMP" &&

    # reconstruct the XPM using the saved alpha channel
    pngtopnm "$PNG" |
    ppmtoxpm -alphamask="$ALPHA_TEMP" -name="$NAME" >"$XPM"
done
