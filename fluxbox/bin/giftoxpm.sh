#!/bin/sh

alpha_temp="$(tempfile)"

for gif; do
	xpm="$(basename "$gif" .gif).xpm"
	name="$(basename "$xpm" |tr . _)"

	rm -fv "$xpm"

	# extract the alpha channel
	giftopnm --alphaout="$alpha_temp" "$gif" >/dev/null
	# reconstruct the XPM using the saved alpha channel
	giftopnm "$gif" | ppmtoxpm -alphamask="$alpha_temp" -name="$name" >"$xpm"
done

rm -f "$alpha_temp"
